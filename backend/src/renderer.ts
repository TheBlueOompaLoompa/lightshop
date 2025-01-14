import { z } from "zod";
import { Canvas, createCanvas, type SKRSContext2D } from '@napi-rs/canvas';
import { Parameter, STreeClip, apiClip } from "$schema/clip";
import effects from "animations/effects";
import Animation, { MixType } from "$lib/animation";
import { Vec3 } from "$schema/settings";
import Color from "$lib/color";
import _ from 'lodash';

declare var self: Worker;

let ws: any;
let layers: Animation[] = [];
let out: Uint32Array | undefined;
let ledCount: number = 1;
let spatialData: { positions: z.infer<typeof Vec3>[], bounds: z.infer<typeof Vec3>[] } | undefined;
let canvas: Canvas | undefined;
let ctx: SKRSContext2D | undefined;

self.onmessage = async (event: MessageEvent) => {
    const msg = SMessage.parse(event.data);
    try {
        switch(msg.type) {
            case 'clip':
                onClip(msg);
                break;
            case 'render':
                onRender(msg);
                break;
            case 'connect':
                await onConnect(msg);
                break;
        }
    }catch(e) {
        console.log(`--Renderer Error Dump--\nDevice: ${ws?.url}\n${e}`);
    }
};

async function setupWs(msg: ConnectMessage) {
    console.log(msg.uri);
    ws = await Bun.udpSocket({
        connect: {
            hostname: msg.uri,
            port: 8080
        }
    });
    if(msg.spatialData) {
        canvas = createCanvas(Math.abs(msg.spatialData.bounds[1][0]-msg.spatialData.bounds[0][0]), Math.abs(msg.spatialData.bounds[1][1]-msg.spatialData.bounds[0][1]));
        ctx = canvas.getContext('2d');
    }

    if(!ws) return;
    let on = true;
    const delay = 200;
    const amount = 1.5;

    const int = setInterval(() => {
        if(!out || !ws) return;
        on = !on;
        out.fill(on ? 0xFFFFFFFF : 0);
        sendZip(ws, new Uint8Array(out.buffer));
    }, delay);

    setTimeout(() => {
        clearInterval(int);
        if(!out || !ws) return;
        out.fill(0);
        sendZip(ws, new Uint8Array(out.buffer));
    }, delay*amount*3);
    
    console.log(`Connected to ws://${msg.uri}:8080`);
}

async function onConnect(msg: ConnectMessage) {
    out = new Uint32Array(msg.ledCount);
    ledCount = msg.ledCount;
    spatialData = msg.spatialData;

    await setupWs(msg)
}

function addComponentRgb(a: number, b: number): number {
    return ((((a >> 24) & 0xff) + ((b >> 24) & 0xff)) << 24) | ((((a >> 16) & 0xff) + ((b >> 16) & 0xff)) << 16) | ((((a >> 8) & 0xff) + ((b >> 8) & 0xff)) << 8)
}

function multComponentRgb(a: number, b: number): number {
    return (
    ((
        (((a >> 24) & 0xff)/255) *
        (((b >> 24) & 0xff)/255) * 255
    ) << 24) | ((
        (((a >> 16) & 0xff)/255) *
        (((b >> 16) & 0xff)/255) * 255
    ) << 16) | ((
        (((a >> 8) & 0xff)/255) *
        (((b >> 8) & 0xff)/255) * 255
    ) << 8)
    );
}

function gammaComponentRgb(a: number, rg: number, gg: number, bg: number): number {
    return (
    ((
        Math.min(Math.pow(((a >> 24) & 0xff)/255, rg) * 255, 255)
    ) << 24) | ((
        Math.min(Math.pow(((a >> 16) & 0xff)/255, gg) * 255, 255)
    ) << 16) | ((
        Math.min(Math.pow(((a >> 8) & 0xff)/255, bg) * 255, 255)
    ) << 8)
    );
}

const flipX = false;
const flipY = true;

function onRender(msg: RenderMessage) {
    if(!out) return;

    out.fill(0);
    if(msg.percent <= 1 && msg.percent >= 0) {
        let time = msg.percent;

        let renderedLayers: Uint32Array[] = [];
        let mixTypes: MixType[] = [];

        for(let i = 0; i < layers.length; i++) {
            let obj = { time, out, ledCount, spatialData, extra: { realTime: msg.percent }, ctx, canvas };
            const extra = layers[i].render(obj);

            if(extra) {
                if(typeof extra.canvas != 'undefined' && canvas && ctx && spatialData) {
                    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                    for(let i = 0; i < ledCount; i++) {
                        if(spatialData.positions[i][2] < spatialData.bounds[2][2] == flipX) continue;
                        const xFactor = canvas.width/(spatialData.bounds[1][0] - spatialData.bounds[0][0]);
                        const yFactor = canvas.height/(spatialData.bounds[0][1] - spatialData.bounds[1][1]);

                        let x = Math.min(Math.floor(xFactor * spatialData.positions[i][0]), canvas.width-1);
                        let y = Math.min(Math.floor(yFactor * spatialData.positions[i][1]), canvas.height-1);

                        if(x >= canvas.width || x < 0) continue;
                        if(y >= canvas.height || y < 0) continue;

                        if(flipX) x = canvas.width-1-x;
                        if(flipY) y = canvas.height-1-y;

                        const ledi = y*canvas.width+x;

                        out[i] = Color.fromRgb(
                            imgData.data[ledi*4]*imgData.data[ledi*4+3]/255,
                            imgData.data[ledi*4+1]*imgData.data[ledi*4+3]/255,
                            imgData.data[ledi*4+2]*imgData.data[ledi*4+3]/255
                        ).raw();
                    }
                }

                if(typeof extra.layer != 'undefined') {
                    mixTypes.push(extra.mix);
                    renderedLayers = [...renderedLayers, extra.layer];
                    out.fill(0);
                }
                
                if(typeof extra.time != 'undefined') {
                    time = extra.time;
                }
            }
        }

        for(let i = 0; i < renderedLayers.length; i++) {
            if(mixTypes[i] == MixType.Add) {
                for(let j = 0; j < out.length; j++) {
                    out[j] = addComponentRgb(out[j], renderedLayers[i][j]);
                }
            }else if(mixTypes[i] == MixType.Multiply) {
                for(let j = 0; j < out.length; j++) {
                    out[j] = multComponentRgb(out[j], renderedLayers[i][j]);
                }
            }else if(mixTypes[i] == MixType.Overlay) {
                for(let j = 0; j < out.length; j++) {
                    out[j] = out[j] > 0 ? out[j] : renderedLayers[i][j];
                }
            }
        }

        /*for(let i = 0; i < out.length; i++) {
            out[i] = gammaComponentRgb(out[i], 2.8, 2.8, 2.8);
        }*/
        
    }

    if(ws) sendZip(ws, new Uint8Array(out.buffer));
}

function sendZip(ws, buf) {
    ws.send(Bun.gzipSync(buf));
}

function onClip(msg: ClipMessage) {
    const { clip } = msg;
    if(!clip.name) return;
    
    layers = [];
    for(let i = 0; i < clip.effects.length; i++) {
        layers.push(effects[clip.effects[i].name].clone());
        layers[i].params = clip.effects[i].params as z.infer<typeof Parameter>[];
    }

}

const SRenderMessage = z.object({ type: z.literal('render'), percent: z.number() });
const SConnectMessage = z.object({
    type: z.literal('connect'),
    uri: z.string(),
    ledCount: z.number(),
    spatialData: z.optional(z.object({ positions: Vec3.array(), bounds: Vec3.array().length(3) })) });
const SClipMessage = z.object({ type: z.literal('clip'), clip: STreeClip });

const SMessage = z.discriminatedUnion('type',
    [SRenderMessage, SConnectMessage, SClipMessage]
);

export type Message = z.infer<typeof SMessage>;
type ClipMessage = z.infer<typeof SClipMessage>;
type RenderMessage = z.infer<typeof SRenderMessage>;
export type ConnectMessage = z.infer<typeof SConnectMessage>;
