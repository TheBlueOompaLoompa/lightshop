import { z } from "zod";

declare var self: Worker;

self.onmessage = (event: MessageEvent) => {
    const msg = SMessage.parse(event.data);
    switch(msg.type) {
        case 'beat':
            beatMsg(msg);
            break;
        default:
            break;
    }
};

function beatMsg(msg: BeatMessage) {
    
}

const SBeatMessage = z.object({ type: z.literal('beat'), time: z.number() });
export const SMessage = z.discriminatedUnion('type', [
    SBeatMessage
]);

type Message = z.infer<typeof SMessage>;
type BeatMessage = z.infer<typeof SBeatMessage>;
