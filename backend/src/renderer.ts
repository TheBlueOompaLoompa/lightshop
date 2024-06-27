import { z } from "zod";
import { Parameter, apiClip } from "$schema/clip";
import animations from "animations/animations";
import type Animation from "$lib/animation";
import { Vec3 } from "$schema/settings";

declare var self: Worker;

let ws: WebSocket | undefined;
let anim: Animation | undefined;
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

function onConnect(msg: ConnectMessage) {
    ws = new WebSocket(msg.uri);
    ws.onopen = () => {
        out = new Uint32Array(msg.ledCount);
        ledCount = msg.ledCount;
        spatialData = msg.spatialData;
    };
}

function onRender(msg: RenderMessage) {
    if(anim && ws && out && ws.readyState == ws.OPEN && spatialData) {
        anim.render({ time: msg.percent, out, ledCount, spatialData })
    }
}

function onClip(msg: ClipMessage) {
    const { clip } = msg;
    if(!clip.name) return;
    anim = animations[clip.name];
    if(anim) {
        anim.params = clip.params as z.infer<typeof Parameter>[];
    }
}

const SRenderMessage = z.object({ type: z.literal('render'), percent: z.number() });
const SConnectMessage = z.object({ type: z.literal('connect'), uri: z.string(), ledCount: z.number(), spatialData: z.optional(Vec3.array()) });
const SClipMessage = z.object({ type: z.literal('clip'), clip: apiClip });

const SMessage = z.discriminatedUnion('type',
    [SRenderMessage, SConnectMessage, SClipMessage]
);

export type Message = z.infer<typeof SMessage>;
type ClipMessage = z.infer<typeof SClipMessage>;
type RenderMessage = z.infer<typeof SRenderMessage>;
type ConnectMessage = z.infer<typeof SConnectMessage>;
