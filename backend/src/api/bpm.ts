import { diskDB } from "db";
import { publicProcedure, router } from "../trpc";
import { z } from "zod";
import { and, eq } from "drizzle-orm";
import { bpms, insertBpm } from "$schema/bpm";
import { EventEmitter } from 'events';
import { observable } from '@trpc/server/observable';
import { caller } from 'index';

const ee = new EventEmitter();

export default router({
    list: publicProcedure
        .input(z.string({ description: 'Project' }))
        .query(async opts => {
            return await diskDB.select()
                .from(bpms)
                .where(eq(bpms.project, opts.input));
        }),
    add: publicProcedure
        .input(insertBpm)
        .mutation(async opts => {
            return await diskDB.insert(bpms)
                .values(opts.input)
        }),
    update: publicProcedure
        .input(insertBpm)
        .mutation(async opts => {
            return await diskDB.update(bpms)
                .set(opts.input)
                .where(and(eq(bpms.beat, opts.input.beat), eq(bpms.project, opts.input.project)))
        }),
    delete: publicProcedure
        .input(insertBpm)
        .mutation(async opts => {
            await diskDB.delete(bpms)
                .where(and(eq(bpms.project, opts.input.project), eq(bpms.beat, opts.input.beat)));
        })
    
});
