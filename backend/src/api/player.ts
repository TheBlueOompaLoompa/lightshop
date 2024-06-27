import { z } from "zod";
import { publicProcedure, router } from "../trpc";
import ZWorker from "$lib/zodworker";
import type { Message as PlayerMessage } from "../player"

const player = new ZWorker<PlayerMessage>('player.ts');

export default router({
    setTime: publicProcedure
        .input(z.number())
        .mutation(opts => {
            player.msg({ type: 'beat', time: opts.input });
        }),
    watchTime: publicProcedure
        .subscription(opts => {

        })
})
