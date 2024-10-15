import ZodWorker from "$lib/zodworker";
import { RenderTarget } from "$schema/settings";
import { z } from "zod";
import type { Message as RenderMessage, ConnectMessage } from "./renderer";
import { apiClip, type TreeClip } from "$schema/clip";
import { insertBpm } from "$schema/bpm";

declare var self: Worker;

class TargetWorker<T> extends ZodWorker<T> {
    name: string = '';
    lastClip: TreeClip | undefined;
}

let targets: TargetWorker<RenderMessage>[] = [];
let targetClips: TargetClips = {};

let beat = 0;

function clipsMsg(msg: ClipsMessage) {
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

function beatMsg(msg: BeatMessage) {
    beat = msg.beat;
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

let originalOpen: OpenMessage | null = null;

function openMsg(msg: OpenMessage) {
    originalOpen = msg;
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

        let msg: ConnectMessage = {
            type: 'connect',
            uri: target.address,
            ledCount: target.ledCount,
        };

        if(Object.keys(target).includes('ledPositions') && target.ledPositions) {
            let lowerBound = [9990, 9990, 10000];
            let upperBound = [0, 0, 0];
            for(let i = 0; i < target.ledCount; i++) {
                for(let j = 0; j < 3; j++) {
                    lowerBound[j] = Math.min(target.ledPositions[i][j], lowerBound[j]);
                    upperBound[j] = Math.max(target.ledPositions[i][j], upperBound[j]);
                }
            }

            const center = [(lowerBound[0] + upperBound[0])/2, (lowerBound[1] + upperBound[1])/2, (lowerBound[2] + upperBound[2])];

            msg.spatialData = {
                positions: target.ledPositions,
                bounds: [lowerBound, upperBound, center]
            };
        }

        renderer.msg(msg);
        renderer.ref();
        targets.push(renderer);
    });
}

function bpmMsg(msg: BpmsMessage) {

}

const SBeatMessage = z.object({ type: z.literal('beat'), beat: z.number() });
const SOpenMessage = z.object({ type: z.literal('open'), targets: z.array(z.object({ id: z.number(), target: RenderTarget})) });
const SSetClips = z.object({ type: z.literal('clips'), clips: z.array(apiClip) });
const SSetBpms = z.object({ type: z.literal('bpms'), bpms: z.array(insertBpm) })

export const SMessage = z.discriminatedUnion('type', [
    SBeatMessage,
    SOpenMessage,
    SSetClips,
    SSetBpms,
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
        case 'bpms':
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
type BpmsMessage = z.infer<typeof SSetBpms>;
