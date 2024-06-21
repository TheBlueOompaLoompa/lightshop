extern crate websocket;

use std::thread;
use websocket::sync::Server;
use websocket::OwnedMessage;

use rs_ws281x::ControllerBuilder;
use rs_ws281x::ChannelBuilder;
use rs_ws281x::StripType;

fn main() {
	let server = Server::bind("0.0.0.0:8080").unwrap();

	for request in server.filter_map(Result::ok) {
		// Spawn a new thread for each connection.
		thread::spawn(|| {
			let mut client = request.accept().unwrap();
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

            let ip = client.peer_addr().unwrap();

			println!("Connection from {}", ip);

			let message = OwnedMessage::Text("Hello".to_string());
			client.send_message(&message).unwrap();

			let (mut receiver, mut sender) = client.split().unwrap();

			for message in receiver.incoming_messages() {
				let message = message.unwrap();

				match message {
					OwnedMessage::Close(_) => {
						let message = OwnedMessage::Close(None);
						sender.send_message(&message).unwrap();
						println!("Client {} disconnected", ip);
						return;
					}
					OwnedMessage::Ping(ping) => {
						let message = OwnedMessage::Pong(ping);
						sender.send_message(&message).unwrap();
					}
                    OwnedMessage::Binary(bin) => {
                        {
                            let leds = controller.leds_mut(0);
                            
                            let mut i = 0;
                            for led in &mut *leds {
                                *led = [bin[i+2], bin[i+3], bin[i+1], bin[i]];
                                i+=4;
                            }
                        }

                        controller.render().unwrap();
                    }
					_ => sender.send_message(&message).unwrap(),
				}
			}
		});
	}
}

