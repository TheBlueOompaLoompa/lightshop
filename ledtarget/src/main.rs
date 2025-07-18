use std::thread::JoinHandle;
use std::{char, fs, mem, thread};
use std::sync::{Arc, Mutex};
use std::net::{SocketAddr, UdpSocket};
use std::io::{Error, ErrorKind, Read};
use std::time::Duration;
use std::path::Path;
use flate2::read::GzDecoder;
use rs_ws281x::ControllerBuilder;
use rs_ws281x::ChannelBuilder;
use rs_ws281x::StripType;
use serde::{Deserialize, Serialize};

const MAGIC: [u8; 2] = [0x1, 0xed];
const BEACON_PORT: u16 = 1336;
const CONFIG_PORT: u16 = 1335;
const CONFIG_PATH: &str = "/etc/lightshop_config.json";

#[derive(Serialize, Deserialize, Clone)]
struct Vector3 {
    x: f32,
    y: f32,
    z: f32,
}

#[derive(Serialize, Deserialize, Clone)]
enum Platform {
    LINEAR { format: StripType, max_brightness: u8, freq: u32, dma: i32, },
    SPATIAL { format: StripType, max_brightness: u8, freq: u32, dma: i32, points: Vec<Vector3>, },
    BINARY,
    MOTION,
}

#[derive(Serialize, Deserialize, Clone)]
struct Output {
    name: String,
    platform: Platform,
    count: u16,
    output_pins: Vec<i32>,
    port: u16,
}

#[derive(Serialize, Deserialize, Clone)]
struct Config {
    name: String,
    outputs: Vec<Output>,
}

#[derive(Serialize, Deserialize)]
enum ControlMsg {
    INTROSPECT {},
    CONFIG { new_config: Config },
    RESTART { output_name: String },
}

struct PlayerThread {
    name: String,
    handle: Option<JoinHandle<Result<(), Error>>>,
    quit: Arc<Mutex<bool>>,
    run_wait: Arc<Mutex<bool>>
}

impl PlayerThread {
    fn new(output: &Output) -> Self {
        PlayerThread { name: output.name.clone(), handle: None, quit: Arc::new(Mutex::new(false)), run_wait: Arc::new(Mutex::new(false)) }
    }

    fn restart_thread(&mut self, output: &Output) {
        match &self.handle {
            Some(_) => {
                let mut quit = self.quit.lock().unwrap();
                *quit = true;
            }
            None => {}
        }
        let out = output.clone();
        let quit = Arc::clone(&self.quit);
        let run_lock = Arc::clone(&self.run_wait);

        let _lock = self.run_wait.lock();
        self.handle = Some(thread::spawn(move || {
            player_thread(out, run_lock, quit)
        }));
    }
}

fn main() {
    let mut config = Config{ name: String::from("Unnamed"), outputs: vec![] };
    let path = Path::new(CONFIG_PATH);
    if fs::exists(path).unwrap() {
        match fs::read(path) {
            Ok(bytes) => {
                let json_res = serde_json::from_str::<Config>(&String::from_utf8(bytes).unwrap().as_str());
                match json_res {
                    Ok(conf) => {
                        config = conf;
                    },
                    Err(_) => {}
                }
            },
            Err(_) => {} 
        }
    }

    let mut config_arc = Arc::new(Mutex::new(config.clone()));
    let player_threads: Vec<PlayerThread> = vec![];
    let player_threads_arc = Arc::new(Mutex::new(player_threads));

    let beacon_handle = thread::spawn(beacon_thread);
    let control_handle = thread::spawn(move || -> std::io::Result<()> {
        control_thread(Arc::clone(&config_arc), Arc::clone(&player_threads_arc))
    });

    let _ = beacon_handle.join();
    let _ = control_handle.join();
}

fn beacon_thread() -> std::io::Result<()> {
    let socket = UdpSocket::bind("0.0.0.0:0").expect(format!("Unable to bind beacon *:{BEACON_PORT}").as_str());
    socket.set_broadcast(true)?;

    let mut beacon_payload: Vec<u8> = MAGIC.to_vec();
    beacon_payload.append(&mut CONFIG_PORT.to_le_bytes().to_vec());
    beacon_payload.append(&mut CONFIG_PORT.to_le_bytes().to_vec());

    loop {
        socket.send_to(&beacon_payload, format!("127.0.0.1:{BEACON_PORT}"))?;
        thread::sleep(Duration::from_secs(1));
    }
}

fn control_thread(config_mutex: Arc<Mutex<Config>>, player_threads_mutex: Arc<Mutex<Vec<PlayerThread>>>) -> std::io::Result<()> {
    let socket = UdpSocket::bind(format!("0.0.0.0:{CONFIG_PORT}")).expect(format!("Unable to bind config *:{CONFIG_PORT}").as_str());
    
    loop {
        let mut raw = [0; 2048];
        let (size, src) = socket.recv_from(&mut raw)?;

        unsafe {
            let raw_json: String = String::from_raw_parts(raw.as_mut_ptr(), size, 2048);
            let raw_json = mem::ManuallyDrop::new(raw_json);
            let json = mem::ManuallyDrop::new(raw_json.trim_end_matches(char::from(0)).to_string());
            println!("{:?}", json);

            let msg_res: std::result::Result<ControlMsg, serde_json::Error> = serde_json::from_str(json.as_str());
            mem::drop(&raw_json);
            mem::drop(&json);
         
            match msg_res {
                Ok(msg) => {
                    handle_control_msg(&socket, src, msg, &config_mutex, &player_threads_mutex);
                },
                Err(e) => { println!("{}", e); }
            }
        }
    }
}

fn handle_control_msg(socket: &UdpSocket, src: SocketAddr, msg: ControlMsg, config_mutex: &Arc<Mutex<Config>>, player_threads_mutex: &Arc<Mutex<Vec<PlayerThread>>>) {
    match msg {
        ControlMsg::INTROSPECT {} => {
            let guard_res = config_mutex.lock();
            match guard_res {
                Ok(config) => {
                    let str_res = serde_json::to_string(&ControlMsg::CONFIG { new_config: config.clone() } );
                    let _ = str_res.inspect(|str| { let _ = socket.send_to(str.as_bytes(), src); });
                },
                Err(_) => {}
            }
        },
        ControlMsg::CONFIG { new_config } => {
            let guard_res = config_mutex.lock();
            match guard_res {
                Ok(mut config) => {
                    *config = new_config.clone();
                    let path = Path::new(CONFIG_PATH);
                    match serde_json::to_string(&*config) {
                        Ok(contents) => { let _ = fs::write(path, contents); },
                        Err(_) => {},
                    }
                },
                Err(_) => {}
            }
        },
        ControlMsg::RESTART { output_name } => {
            let mut threads = player_threads_mutex.lock().unwrap();
            let config = config_mutex.lock().unwrap();

            let output_res = config.outputs.iter().find(|&out| out.name == output_name);
            
            match output_res {
                Some(output) => {
                    let mut thread_found = false;
                    for i in 0..threads.len() {
                        if threads[i].name == output_name {
                            thread_found = true;
                            threads[i].restart_thread(output);
                        }
                    }

                    if !thread_found {
                        threads.push(PlayerThread::new(output));
                    }
                },
                None => {}
            }
        }
    }
}

fn player_thread(output: Output, run_lock: Arc<Mutex<bool>>, quit: Arc<Mutex<bool>>) -> std::io::Result<()> {
    let _lock = run_lock.lock();
    let socket = UdpSocket::bind(format!("0.0.0.0:{}", output.port)).expect(format!("Unable to bind player to *:{}", output.port).as_str());
    socket.set_nonblocking(true)?;
    
    match output.platform {
        Platform::LINEAR { format, max_brightness, freq, dma } => {
            led_player(&socket, output, format, max_brightness, freq, dma, &quit);
        },
        Platform::SPATIAL { format, max_brightness, freq, dma, points: _ } => {
            led_player(&socket, output, format, max_brightness, freq, dma, &quit);
        },
        Platform::BINARY => {

        },
        Platform::MOTION => {

        }
    }

    Ok(())
}

fn led_player(socket: &UdpSocket, output: Output, strip_type: StripType, brightness: u8, freq: u32, dma: i32, quit: &Arc<Mutex<bool>>) {
    let mut raw: Vec<u8> = Vec::new();
    let mut buf: Vec<u8> = Vec::new();

    raw.resize(output.count as usize*4, 0);
    buf.resize(output.count as usize*4, 0);

    let mut controller = ControllerBuilder::new()
        .freq(freq) // 800_000
        .dma(dma) // 10
        .channel(
            0, // Channel Index
            ChannelBuilder::new()
                .pin(output.output_pins[0]) // GPIO 18
                .count(output.count.into()) // 541 Number of LEDs
                .strip_type(strip_type)
                .brightness(brightness) // default: 255
                .build(),
        )
        .build().unwrap();
    
    loop {
        match socket.recv(&mut raw) {
            Ok(_len) => {
                let mut gz = GzDecoder::new(&raw[..]);
                let size = gz.read(&mut buf);
             
                {
                    let leds = controller.leds_mut(0);
                    
                    let mut i = 0;
                    for led in &mut *leds {
                        *led = [buf[i+1], buf[i+0], buf[i+2], buf[i+3]];
                        i+=4;
                    }
                }
             
                controller.render().unwrap();
            },
            Err(e) => {
                if !matches!(e.kind(), ErrorKind::WouldBlock) {
                    eprintln!("{}", e)
                }
            }
        }

        match quit.lock() {
            Ok(q) => {
                if *q { return; }
            },
            Err(_) => {},
        }
    }
}
