import ZodWorker from "$lib/zodworker";
import { RenderTarget } from "$schema/settings";
import { z } from "zod";
import type { Message as RenderMessage } from "./renderer";
import { apiClip, type TreeClip } from "$schema/clip";

declare var self: Worker;

class TargetWorker<T> extends ZodWorker<T> {
    name: string = '';
    lastClip: TreeClip | undefined;
}

let targets: TargetWorker<RenderMessage>[] = [];
let targetClips: TargetClips = {};

let beat = 0;

function clipsMsg(msg: ClipsMessage) {
    // TODO: Support tree
    msg.clips.forEach((clip: any) => {
        try {
            const data = Object.entries(targetClips).find(item => item[1].id == clip.parent) as any
            if(data) {
                let targetRef = data[1] as unknown as TreeClip;
                const existingIdx = targetRef.children.findIndex(child => child.id == clip.id);
                if(clip.name == "delete") {
                    // Delete
                    targetRef.children.splice(existingIdx, 1);
                }else {
                    // Update
                    if(existingIdx > -1) targetRef.children[existingIdx] = makeClip(clip);
                    // New
                    else targetRef.children.push(makeClip(clip));
                }
                beatMsg({ type: 'beat', beat });
            }
        }catch(e) {
            self.postMessage(e);
        }
    });
}

function makeClip(clip: any) {
    return {
        id: clip.id,
        name: clip.name,
        type: clip.type,
        effects: clip.effects,
        start: clip.start,
        end: clip.end,
        children: [],
    }
}

// TODO: Make percent work
function beatMsg(msg: BeatMessage) {
    beat = msg.beat;
    // TODO: Support tree
    targets.forEach(target => {
        const children = targetClips[target.name].children;
        for(let i = 0; i < children.length; i++) {
            if(target.lastClip != children[i] && children[i].start <= msg.beat && children[i].end > msg.beat) {
                target.postMessage({ type: 'clip', clip: children[i] });
                target.lastClip = children[i];
                break;
            }
        }

        if(target.lastClip) {
            target.msg({ type: 'render', percent: (msg.beat - target.lastClip.start) / (target.lastClip.end - target.lastClip.start) });
        }
    });
}

function openMsg(msg: OpenMessage) {
    while(targets.length > 0) {
        targets[0].terminate();
        targets.splice(0, 1);
    }

    msg.targets.forEach(obj => {
        const { id, target } = obj;
        let renderer = new TargetWorker<RenderMessage>('renderer.ts');
        renderer.name = target.name;

        targetClips[target.name] = {
            id,
            type: 'root',
            name: target.name,
            effects: [],
            children: [],
            start: 0,
            end: 0
        };

        renderer.msg({
            type: 'connect',
            uri: target.address,
            ledCount: target.ledCount,
            spatialData: target.ledPositions
        });

        renderer.ref();
        targets.push(renderer);
    });
}

const SBeatMessage = z.object({ type: z.literal('beat'), beat: z.number() });
const SOpenMessage = z.object({ type: z.literal('open'), targets: z.array(z.object({ id: z.number(), target: RenderTarget})) });
const SSetClips = z.object({ type: z.literal('clips'), clips: z.array(apiClip) });

export const SMessage = z.discriminatedUnion('type', [
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
    [key: string]: TreeClip
}

export type Message = z.infer<typeof SMessage>;
type BeatMessage = z.infer<typeof SBeatMessage>;
type OpenMessage = z.infer<typeof SOpenMessage>;
type ClipsMessage = z.infer<typeof SSetClips>;
