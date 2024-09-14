import { z } from "zod";
import { Parameter, STreeClip, apiClip } from "$schema/clip";
import effects from "animations/effects";
import type Animation from "$lib/animation";
import { Vec3 } from "$schema/settings";
import Color from "$lib/color";
import _ from 'lodash';

declare var self: Worker;

let ws: any;
let layers: Animation[] = [];
let out: Uint32Array | undefined;
let ledCount: number = 1;
let spatialData: z.infer<typeof Vec3>[] | undefined;

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

    if(!ws) return;
    let on = true;
    const delay = 200;
    const amount = 1.5;

    const int = setInterval(() => {
        if(!out || !ws) return;
        on = !on;
        out.fill(on ? 0xFFFFFFFF : 0);
        ws.send(new Uint8Array(out.buffer));
    }, delay);

    setTimeout(() => {
        clearInterval(int);
        if(!out || !ws) return;
        out.fill(0);
        ws.send(new Uint8Array(out.buffer));
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

function onRender(msg: RenderMessage) {
    if(!out) return;

    out.fill(0);
    if(msg.percent <= 1 && msg.percent >= 0) {
        let time = msg.percent;

        let renderedLayers: Uint32Array[] = [];

        for(let i = 0; i < layers.length; i++) {
            let obj = { time, out, ledCount, spatialData, extra: { realTime: msg.percent } };
            const extra = layers[i].render(obj);

            if(extra) {
                if(typeof extra.layer != 'undefined') {
                    renderedLayers = [...renderedLayers, extra.layer];
                }
                
                if(typeof extra.time != 'undefined') {
                    time = extra.time;
                }
            }
        }

        for(let i = 0; i < renderedLayers.length; i++) {
            for(let j = 0; j < out.length; j++) {
                out[j] = addComponentRgb(out[j], renderedLayers[i][j]);
            }
        }
        
    }

    if(ws) ws.send(new Uint8Array(out.buffer));
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
const SConnectMessage = z.object({ type: z.literal('connect'), uri: z.string(), ledCount: z.number(), spatialData: z.optional(Vec3.array()) });
const SClipMessage = z.object({ type: z.literal('clip'), clip: STreeClip });

const SMessage = z.discriminatedUnion('type',
    [SRenderMessage, SConnectMessage, SClipMessage]
);

export type Message = z.infer<typeof SMessage>;
type ClipMessage = z.infer<typeof SClipMessage>;
type RenderMessage = z.infer<typeof SRenderMessage>;
type ConnectMessage = z.infer<typeof SConnectMessage>;
