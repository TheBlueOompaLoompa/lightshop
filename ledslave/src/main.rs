use std::net::UdpSocket;

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
                .count(300) // Number of LEDs
                .strip_type(StripType::Ws2811Bgr)
                .brightness(255) // default: 255
                .build(),
        )
        .build()
        .unwrap();
    
    loop {
        let mut buf = [0; 300*3];
        let _ = socket.recv(&mut buf);

        {
            let leds = controller.leds_mut(0);
            
            let mut i = 0;
            for led in &mut *leds {
                *led = [buf[i+2], buf[i+3], buf[i+1], buf[i]];
                i+=4;
            }
        }

        controller.render().unwrap();
    }
}

