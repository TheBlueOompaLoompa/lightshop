import { z } from 'zod';
import { insertProject, projects } from '$schema/project';
import { publicProcedure, router } from '../trpc';
import Cache from '../cache';
import { diskDB } from 'db';
import { eq } from 'drizzle-orm';
import { caller } from '../index';
import _ from 'lodash';
import type { apiClip } from '$schema/clip';

const cache = new Cache();

export default router({
    list: publicProcedure
        .query(async () => {
            return await cache.useCache('project-list', async () => 
                await diskDB.select({ name: projects.name })
                    .from(projects)
            );
        }),
    save: publicProcedure
        .input(insertProject)
        .mutation(async (opts) => {
            await diskDB.insert(projects)
                .values(opts.input)
                .onConflictDoUpdate({
                    target: projects.name,
                    set: opts.input
                });
            cache.invalidate('project-list');
        }),
    delete: publicProcedure
        .input(z.string({ description: 'Project name' }))
        .mutation(async (opts) => {
            await diskDB.delete(projects).where(eq(projects.name, opts.input));
            cache.invalidate('project-list');
        }),
    open: publicProcedure
        .input(z.string())
        .query(async opts => {
            const project = (await diskDB.select().from(projects).where(eq(projects.name, opts.input)))[0];

            const pools = await caller.pools.list(project.name);
            const POOL_NAME = 'Roots';

            // Create Root Pool
            if(!_.some(pools, ['name', POOL_NAME])) {
                await caller.pools.new({ name: POOL_NAME, project: project.name });
            }

            // Create Root Clips
            const settings = await caller.settings.load();
            let rootClips = await caller.clips.list({ pool: POOL_NAME, project: project.name });
            settings.targets.forEach(async target => {
                if(!_.some(rootClips, ['name', target.name])) {
                    await caller.clips.new({
                        name: target.name,
                        type: 'root',
                        pool: POOL_NAME,
                        params: [],
                        project: project.name,
                        targetType: target.type
                    });
                }
            });

            // Setup project player
            rootClips = await caller.clips.list({ pool: POOL_NAME, project: project.name });

            const targets = rootClips.map((root: z.infer<typeof apiClip>) =>
                ({  
                    id: root.id,
                    target: settings.targets.find(target => target.name == root.name)
                }));


            await caller.player.sendMsg({ type: 'open', targets });

            // Load clips into player
            let clips: any[] = [];

            for(let i = 0; i < rootClips.length; i++) {
                clips = [...clips, ...(await caller.clips.listChildren(rootClips[i].id as number))];
            }


            await caller.player.sendMsg({ type: 'clips', clips });

            return {
                project
            };
        }),
});
