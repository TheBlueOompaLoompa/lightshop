import NodeWebcam from 'node-webcam';
import { rmSync } from 'node:fs';
import { Jimp } from "jimp";
import Color from 'ledcolor';
import { $ } from 'bun';

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

let posResolve: any[] = [];
let nextCam: any[] = [];
let nextRes: any[] = [];

Bun.serve({
    port: 3000,
    hostname: '0.0.0.0',
    async fetch(req) {
        const url = new URL(req.url);
        if(url.searchParams.get('x')) {
            const x = parseInt(url.searchParams.get('x') ?? '0');
            const y = parseInt(url.searchParams.get('y') ?? '0');
            posResolve.forEach(res => res([x, y]));
            posResolve = [];
            nextCam.push(new Promise((res) => { nextRes.push(res) }))
            await Promise.all(nextCam);
            nextCam = [];
        }
        const filePath = url.pathname;
        return new Response(Bun.file('static' + filePath));
    },
});

const addr = await prompt('Target IP');
const ledCount = parseInt(await prompt('How many leds?'));

const port = 8080;

const ledBuf = new Uint32Array(ledCount);

const client = await Bun.udpSocket({
    port 
});

function send() {
    client.send(Bun.gzipSync(new Uint8Array(ledBuf.buffer)), port, addr);
}

console.log('Confirming connection...');
ledBuf.fill(Color.fromHex('#ffffff').raw());
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
console.log(NodeWebcam.list());


async function recordSide(): Promise<{ x: number, y: number }[]> {
    let pixels = [];
    for(let i = 0; i < ledCount; i++) {
        ledBuf.fill(0);
        ledBuf[i] = Color.fromRgb(255, 255, 255).raw();
        send();
        //Webcam.capture( "static/image", (err, data) => {});
        await $`fswebcam -r 1280x720 --jpeg 100 -d /dev/video1 -F 2 /tmp/lightcalib.jpg`;
        /*const res = nextRes.pop();
        if(res) res();
        nextRes = [];
        const data = await new Promise((res) => {
            posResolve.push(res);
        });*/
        const image = await Jimp.read("/tmp/lightcalib.jpg");
        //console.log(data);

        const ledPos = findLed(image);
        pixels.push(ledPos);
        console.log(`Leds found ${pixels.length}/${ledCount} at (${ledPos.x}, ${ledPos.y})`);
    }

    return pixels;
}

function findLed(image: any): { x: number, y: number } {
    let out = { x: 0, y: 0 };

    let avgCount = 0;

    let brightnessFloor = 90;
    let maxBright = 0;

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
