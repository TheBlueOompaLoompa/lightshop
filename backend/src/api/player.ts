import { z } from "zod";
import { publicProcedure, router } from "../trpc";
import ZWorker from "$lib/zodworker";
import { SMessage, type Message as PlayerMessage } from "../player"
import { EventEmitter } from "events";
import { observable } from "@trpc/server/observable";

let player = new ZWorker<PlayerMessage>('player.ts');
const ee = new EventEmitter();

player.onerror = (e: ErrorEvent) => {
    console.error(e);
};

export default router({
    sendMsg: publicProcedure
        .input(SMessage)
        .mutation(opts => {
            player.msg(opts.input);
        }),
    setBeat: publicProcedure
        .input(z.number())
        .mutation(opts => {
            ee.emit('beat', opts.input);
            player.msg({ type: 'beat', beat: opts.input });
        }),
    watchBeat: publicProcedure
        .subscription(() => {
            return observable<number>(emit => {
                function onBeat(beat: number) {
                    emit.next(beat);
                }

                ee.on('beat', onBeat);

                return () => {
                    ee.off('beat', onBeat);
                };
            });
        }),
})
