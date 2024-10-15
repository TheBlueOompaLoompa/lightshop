import NodeWebcam from 'node-webcam';
import { rmSync } from 'node:fs';
import { Jimp } from "jimp";
import Color from './color';

async function prompt(question: string, confirm = true) {
    process.stdout.write(question + ': ');
    let out = '';
    let confirming = false;
    for await(const line of console) {
        if(confirming) {
            confirming = false;
            if(line == 'y') {
                break;
            }else if(line == 'n') {
                out = await prompt(question, confirm);
                break;
            }else {
                console.log(`Is "${out}" correct? [y/n]`);
                confirming = true;
            }
        }else {
            out = line;
            if(confirm) {
                console.log(`Is "${out}" correct? [y/n]`);
                confirming = true;
            }else {
                break;
            }
        }
    }

    return out;
}


const addr = await prompt('Target IP');
const ledCount = parseInt(await prompt('How many leds?'));

const port = 8080;

const ledBuf = new Uint8Array(ledCount*4);

const client = await Bun.udpSocket({
    port 
});

function send() {
    client.send(ledBuf, port, addr);
}

console.log('Confirming connection...');
ledBuf.fill(255);
send();
if(await prompt('Is the device lit up? [y/n]', false) == 'n') process.exit(-1);
ledBuf.fill(0);
send();

const webcamOpts = {
    width: 1280,
    height: 720,
    quality: 100,
    delay: 0,
    saveShots: true,
    output: "jpeg",
    device: false,
    callbackReturn: 'location',
    verbose: false,
};

const Webcam = NodeWebcam.create(webcamOpts);


async function recordSide(): Promise<{ x: number, y: number }[]> {
    let pixels = [];
    for(let i = 0; i < ledCount; i++) {
        ledBuf.fill(0);
        for(let j = 0; j < 4; j++) {
            ledBuf[i*4+j] = 255;
        }
        send();
        Webcam.capture( "/tmp/lightcalib", (err, data) => {});
        //await $`ffmpeg -y -f video4linux2 -s 1280x720 -i /dev/video0 -ss 0:0:2 -frames 1 /tmp/lightcalib.jpg`;
        const image = await Jimp.read("/tmp/lightcalib.jpg");

        const ledPos = findLed(image);
        pixels.push(ledPos);
        console.log(`Leds found ${pixels.length}/${ledCount}`);
    }

    return pixels;
}

function findLed(image: any): { x: number, y: number } {
    let out = { x: 0, y: 0 };

    let avgCount = 0;


    let brightnessFloor = 90;
    let maxBright =0;

    while(avgCount < 1) {
        for(let y = 0; y < image.height; y++) {
            for(let x = 0; x < image.width; x++) {
                const color = Color.fromRaw(image.getPixelColor(x, y));
                if(color.v > maxBright) maxBright = color.v;
                
                if(color.v > brightnessFloor) {
                    out.x += x;
                    out.y += y;
                    avgCount += 1;
                }
            }
        }
        brightnessFloor -= 1;
    }
    
    out.x /= avgCount;
    out.y /= avgCount;

    return out;
}

// Capture axis
const xAxis = await recordSide();

await prompt('Press enter to capture next phase', false);

const yAxis = await recordSide();

// Calculate farthest top and bottom for scaling
let top = 0;
let bottom = 0;
for(let i = 0; i < xAxis.length; i++) {
    const pixel = xAxis[i];

    if(pixel.y > xAxis[top].y) top = i;
    if(pixel.y < xAxis[bottom].y) bottom = i;
}

const xTop = xAxis[top].y;
const xBottom = xAxis[bottom].y;
const yTop = yAxis[top].y;
const yBottom = yAxis[bottom].y;

const scale = (xTop-xBottom)/(yTop-yBottom)
const yOffset = xBottom - yBottom;

// Rescale
for(let i = 0; i < yAxis.length; i++) {
    yAxis[i].x = yAxis[i].x*scale;
    yAxis[i].y = (yAxis[i].y - yOffset) * scale;
}

// Final Formatting
rmSync('calibration.txt');
const file = Bun.file('calibration.txt');
const writer = file.writer();
writer.start();

for(let i = 0; i < ledCount; i++) {
    const point = { x: xAxis[i].x, y: yAxis[i].y, z: yAxis[i].x };
    writer.write(`${point.x};${point.y};${point.z}`);
    if(i < ledCount - 1) writer.write('\n');
}

writer.end();
console.log('Calibration complete');
process.exit();
