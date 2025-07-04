use std::{char, mem, thread};
use std::sync::{Arc, Mutex};
use std::net::{SocketAddr, UdpSocket};
use std::io::Read;
use std::time::Duration;
use flate2::read::GzDecoder;
use rs_ws281x::ControllerBuilder;
use rs_ws281x::ChannelBuilder;
use rs_ws281x::StripType;
use serde::{Deserialize, Serialize};

const MAGIC: [u8; 2] = [0x1, 0xed];
const BEACON_PORT: u16 = 1336;
const CONFIG_PORT: u16 = 1335;
const PLAYER_PORT: u16 = 8080;

#[derive(Serialize, Deserialize, Clone)]
enum Platform {
    LINEAR,
    SPATIAL,
    BINARY,
    MOTION,
}

#[derive(Serialize, Deserialize, Clone)]
struct Output {
    name: String,
    platform: Platform,
    count: u32,
    output_pins: Vec<u8>,
}

#[derive(Serialize, Deserialize, Clone)]
struct Config {
    name: String,
    outputs: Vec<Output>,
}

#[derive(Serialize, Deserialize)]
enum ConfigMsg {
    INTROSPECT {},
    CONFIG { new_config: Config }
}


fn main() {
    let mut config = Arc::new(Mutex::new(Config{ name: String::from("Hello"), outputs: vec![] }));
    let config_config_arc = Arc::clone(&config);
    let player_config_arc = Arc::clone(&config);

    let beacon_handle = thread::spawn(beacon_thread);
    let config_handle = thread::spawn(move || -> std::io::Result<()> {
        config_thread(config_config_arc)
    });
    //let player_handle = thread::spawn(player_thread);

    let _ = beacon_handle.join();
    let _ = config_handle.join();
    //let _ = player_handle.join();
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

fn config_thread(config_mutex: Arc<Mutex<Config>>) -> std::io::Result<()> {
    let socket = UdpSocket::bind(format!("0.0.0.0:{CONFIG_PORT}")).expect(format!("Unable to bind config *:{CONFIG_PORT}").as_str());
    
    loop {
        let mut raw = [0; 2048];
        let (size, src) = socket.recv_from(&mut raw)?;

        unsafe {
            let raw_json: String = String::from_raw_parts(raw.as_mut_ptr(), size, 2048);
            let raw_json = mem::ManuallyDrop::new(raw_json);
            let json = mem::ManuallyDrop::new(raw_json.trim_end_matches(char::from(0)).to_string());
            println!("{:?}", json);

            let msg_res: std::result::Result<ConfigMsg, serde_json::Error> = serde_json::from_str(json.as_str());
            mem::drop(&raw_json);
            mem::drop(&json);
         
            match msg_res {
                Ok(msg) => {
                    handle_config_msg(&socket, src, msg, &config_mutex);
                },
                Err(e) => { println!("{}", e); }
            }
        }
    }
}

fn handle_config_msg(socket: &UdpSocket, src: SocketAddr, msg: ConfigMsg, config_mutex: &Arc<Mutex<Config>>) {
    match msg {
        ConfigMsg::INTROSPECT {} => {
            let guard_res = config_mutex.lock();
            match guard_res {
                Ok(config) => {
                    let str_res = serde_json::to_string(&ConfigMsg::CONFIG { new_config: config.clone() } );
                    let _ = str_res.inspect(|str| { let _ = socket.send_to(str.as_bytes(), src); });
                },
                Err(_) => {}
            }
        },
        ConfigMsg::CONFIG { new_config } => {
            let guard_res = config_mutex.lock();
            match guard_res {
                Ok(mut config) => {
                    *config = new_config.clone();
                },
                Err(_) => {}
            }
        }
    }
}

fn player_thread() -> std::io::Result<()> {
    let socket = UdpSocket::bind(format!("0.0.0.0:{PLAYER_PORT}")).expect(format!("Unable to bind player to *:{PLAYER_PORT}").as_str());

    let mut controller = ControllerBuilder::new()
        .freq(800_000)
        .dma(10)
        .channel(
            0, // Channel Index
            ChannelBuilder::new()
                .pin(18) // GPIO 10 = SPI0 MOSI
                .count(541) // 541 Number of LEDs
                .strip_type(StripType::Ws2811Bgr)
                .brightness(255) // default: 255
                .build(),
        )
        .build().unwrap();
    
    loop {
        let mut raw = [0; 541*4];
        socket.recv(&mut raw)?;
        let mut gz = GzDecoder::new(&raw[..]);
	    let mut buf = [0; 541*4];
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
    }
}
