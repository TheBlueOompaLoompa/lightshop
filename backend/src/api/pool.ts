import { diskDB } from "db";
import { publicProcedure, router } from "../trpc";
import { insertPool, pools } from "$schema/pool";
import { z } from "zod";
import { eq, isNull, or } from "drizzle-orm";

export default router({
    new: publicProcedure
        .input(insertPool)
        .mutation(async opts => {
            return await diskDB.insert(pools)
                .values(opts.input);
        }),
    list: publicProcedure
        .input(z.string())
        .query(async opts => {
            return await diskDB.select()
                .from(pools)
                .where(or(eq(pools.project, opts.input), isNull(pools.project)))
        })
});
