import { z } from "zod";
import { Parameter, STreeClip, apiClip } from "$schema/clip";
import effects from "animations/effects";
import type Animation from "$lib/animation";
import { Vec3 } from "$schema/settings";
import Color from "$lib/color";

declare var self: Worker;

let ws: WebSocket | undefined;
let layers: Animation[] = [];
let out: Uint32Array | undefined;
let ledCount: number = 1;
let spatialData: z.infer<typeof Vec3>[] | undefined;

self.onmessage = (event: MessageEvent) => {
    const msg = SMessage.parse(event.data);

    switch(msg.type) {
        case 'clip':
            onClip(msg);
            break;
        case 'render':
            onRender(msg);
            break;
        case 'connect':
            onConnect(msg);
            break;
    }
};

const onOpen = (msg: ConnectMessage) => {
    if(!ws) return;
    out = new Uint32Array(msg.ledCount);
    ledCount = msg.ledCount;
    spatialData = msg.spatialData;

    let on = true;
    const delay = 200;
    const amount = 2.5;
    const int = setInterval(() => {
        if(!out || !ws) return;
        on = !on;
        out.fill(on ? 0xFFFFFFFF : 0);
        ws.send(out);
    }, delay);

    setTimeout(() => {
        clearInterval(int);
        if(!out || !ws) return;
        out.fill(0);
        ws.send(out);
    }, delay*amount*3);

    console.log(`Connected to ws://${msg.uri}:8080`);

    ws.onclose = () => {
        ws = new WebSocket(`ws://${msg.uri}:8080`);
        ws.onopen = () => onOpen(msg);
    }
};

function onConnect(msg: ConnectMessage) {
    ws = new WebSocket(`ws://${msg.uri}:8080`);
    ws.onopen = () => onOpen(msg);
}

function onRender(msg: RenderMessage) {
    if(ws && out && ws.readyState == ws.OPEN) {
        out.fill(0);
        if(msg.percent <= 1 && msg.percent >= 0) {
            for(let i = 0; i < layers.length; i++) {
                layers[i].render({ time: msg.percent, out, ledCount, spatialData, extra: undefined });
            }
        }
        ws.send(out);
    }
}

function onClip(msg: ClipMessage) {
    const { clip } = msg;
    if(!clip.name) return;
    
    layers = [];
    for(let i = 0; i < clip.effects.length; i++) {
        layers.push(effects[clip.effects[i].name]);
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
