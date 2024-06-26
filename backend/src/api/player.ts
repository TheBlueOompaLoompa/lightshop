import { z } from "zod";
import { publicProcedure, router } from "../trpc";

const player = new Worker('player.ts');

export default router({
    setTime: publicProcedure
        .input(z.number())
        .mutation(opts => {
            player.postMessage({ type: 'time', time: opts.input });
        }),
    watchTime: publicProcedure
        .subscription(opts => {

        })
})
