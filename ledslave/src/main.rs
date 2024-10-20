use std::net::UdpSocket;
use flate2::read::GzDecoder;
use std::io::Read;
use rs_ws281x::ControllerBuilder;
use rs_ws281x::ChannelBuilder;
use rs_ws281x::StripType;

fn main() -> std::io::Result<()> {
    let socket = UdpSocket::bind("0.0.0.0:8080")?;

    let mut controller = ControllerBuilder::new()
        .freq(800_000)
        .dma(10)
        .channel(
            0, // Channel Index
            ChannelBuilder::new()
                .pin(18) // GPIO 10 = SPI0 MOSI
                .count(400) // Number of LEDs
                .strip_type(StripType::Ws2811Bgr)
                .brightness(255) // default: 255
                .build(),
        )
        .build()
        .unwrap();
    
    loop {
        let mut raw = [0; 400*4];
        socket.recv(&mut raw)?;
        let mut gz = GzDecoder::new(&raw[..]);
	let mut buf = [0; 400*4];
        let size = gz.read(&mut buf);

        {
            let leds = controller.leds_mut(0);
            
            let mut i = 0;
            for led in &mut *leds {
                *led = [buf[i+3], buf[i+2], buf[i+1], buf[i+0]];
                i+=4;
            }
        }

        controller.render().unwrap();
    }
}
