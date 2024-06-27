import { publicProcedure, router } from '../trpc';
import Cache from '../cache';
import { z } from 'zod';
import { diskDB } from 'db';
import { apiClip, apiInsertClip, betterApiClip, betterApiInsertClip, clips } from '$schema/clip';
import { and, eq, isNull, or } from 'drizzle-orm';
import { EventEmitter } from 'events';
import { observable } from '@trpc/server/observable';
import { caller } from 'index';

const cache = new Cache();
const ee = new EventEmitter();

export default router({
    list: publicProcedure
        .input(z.object({ pool: z.string(), project: z.string().default('') }))
        .query(async opts => 
            await cache.useCache(`clips-pool-${JSON.stringify(opts.input)}`,
                async () => await diskDB.select()
                    .from(clips)
                    .where(and(eq(clips.pool, opts.input.pool), or(eq(clips.project, opts.input.project), isNull(clips.project))))
            )
        ),
    listChildren: publicProcedure
        .input(z.number({ description: 'Parent id' }))
        .query(async opts => 
            await cache.useCache(`clips-child-${opts.input}`,
                async () => await diskDB.select()
                    .from(clips)
                    .where(eq(clips.parent, opts.input))
            )
        ),
    getById: publicProcedure
        .input(z.number())
        .query(async opts => (await diskDB.select().from(clips).where(eq(clips.id, opts.input)))[0]),
    new: publicProcedure
        .input(betterApiInsertClip)
        .mutation(async opts => {
            cache.groupInvalidate('clips');

            const newClip = await diskDB.insert(clips)
                .values(opts.input)
                .returning();
            
            ee.emit('new', newClip[0], opts.ctx.id);

            return newClip;
        }),
    onNew: publicProcedure
        .subscription(() => {
            return observable<{ id: number, clip: z.infer<typeof betterApiInsertClip>}>(emit => {
                function onNew(clip: any, id: number) {
                    emit.next({ id, clip });
                }

                ee.on('new', onNew);

                return () => {
                    ee.off('new', onNew);
                };
            });
        }),
    delete: publicProcedure
        .input(z.number({ description: 'Clip id' }))
        .mutation(async opts => {
            const clip = await caller.clips.getById(opts.input);
            ee.emit('delete', clip);
            cache.groupInvalidate('clips');
            await diskDB.delete(clips)
                .where(eq(clips.id, opts.input));
        }),
    onDelete: publicProcedure
        .subscription(() => {
            return observable<z.infer<typeof betterApiInsertClip>>(emit => {
                function onDelete(clip: any) {
                    emit.next(clip)
                }

                ee.on('delete', onDelete);

                return () => {
                    ee.off('delete', onDelete);
                };
            });
        }),
    update: publicProcedure
        .input(apiClip)
        .mutation(async opts => {
            if(!opts.input.id) return;

            cache.groupInvalidate('clips');
            ee.emit('update', opts.input, opts.ctx.id);

            return await diskDB.update(clips)
                .set(opts.input)
                .where(eq(clips.id, opts.input.id))
        }),
    onUpdate: publicProcedure
        .subscription(() => {
            return observable<{ id: number, clip: z.infer<typeof betterApiInsertClip>}>(emit => {
                function onUpdate(clip: any, id: number) {
                    emit.next({ id, clip });
                }

                ee.on('update', onUpdate);

                return () => {
                    ee.off('update', onUpdate);
                };
            });
        }),
});

