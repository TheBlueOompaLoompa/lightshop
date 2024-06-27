import ZodWorker from "$lib/zodworker";
import { RenderTarget } from "$schema/settings";
import { z } from "zod";
import type { Message as RenderMessage } from "./renderer";
import { apiClip } from "$schema/clip";

declare var self: Worker;


let targets: ZodWorker<RenderMessage>[] = [];

let targetClips: TargetClips = {};

function clipsMsg(msg: ClipsMessage) {
    targetClips
}

// TODO: Make permsg: ClipsMessagecent work
function beatMsg(msg: BeatMessage) {
    targets.map(target => target.msg({ type: 'render', percent: 0 }));
}

function openMsg(msg: OpenMessage) {
    msg.targets.forEach(target => {
        const renderer = new ZodWorker<RenderMessage>('renderer.ts');
        renderer.msg({
            type: 'connect',
            uri: target.address,
            ledCount: target.ledCount,
            spatialData: target.ledPositions
        });
    });
}

const SBeatMessage = z.object({ type: z.literal('beat'), time: z.number() });
const SOpenMessage = z.object({ type: z.literal('open'), targets: z.array(RenderTarget) });
const SSetClips = z.object({ type: z.literal('clips'), clip: z.array(apiClip) });

const SMessage = z.discriminatedUnion('type', [
    SBeatMessage,
    SOpenMessage,
    SSetClips,
]);

self.onmessage = (event: MessageEvent) => {
    const msg = SMessage.parse(event.data);
    switch(msg.type) {
        case 'beat':
            beatMsg(msg);
            break;
        case 'open':
            openMsg(msg);
            break;
        case 'clips':
            clipsMsg(msg);
            break;
        default:
            break;
    }
};

interface TargetClips {
    [key: string]: z.infer<typeof apiClip>[]
}

export type Message = z.infer<typeof SMessage>;
type BeatMessage = z.infer<typeof SBeatMessage>;
type OpenMessage = z.infer<typeof SOpenMessage>;
type ClipsMessage = z.infer<typeof SSetClips>;
