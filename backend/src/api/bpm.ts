
import { diskDB } from "db";
import { publicProcedure, router } from "../trpc";
import { z } from "zod";
import { and, eq } from "drizzle-orm";
import { bpms, insertBpm } from "$schema/bpm";

export default router({
    listEvents: publicProcedure
        .input(z.string({ description: 'Project' }))
        .query(async opts => {
            return await diskDB.select()
                .from(bpms)
                .where(eq(bpms.project, opts.input));
        }),
    addEvent: publicProcedure
        .input(insertBpm)
        .mutation(async opts => {
            return await diskDB.insert(bpms)
                .values(opts.input)
        }),
    deleteEvent: publicProcedure
        .input(insertBpm)
        .mutation(async opts => {
            await diskDB.delete(bpms)
                .where(and(eq(bpms.project, opts.input.project), eq(bpms.beat, opts.input.beat)));
        })
});
