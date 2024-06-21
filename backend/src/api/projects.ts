import { z } from 'zod';
import { deleteProject, listProjects, loadProject, saveProject, updateConfig } from '../projects';
import { Project, ProjectInfo } from '$schema/project';
import { publicProcedure, router } from '../trpc';
import Cache from '../cache';

const cache = new Cache();

export default router({
    list: publicProcedure
        .query(async () => {
            return await cache.useCache('project-list', listProjects);
        }),
    new: publicProcedure
        .input(Project)
        .mutation(async (opts) => {
            await saveProject(opts.input, true);
            cache.invalidate('project-list');
        }),
    save: publicProcedure
        .input(Project)
        .mutation(async (opts) => {
            await saveProject(opts.input);
            cache.invalidate('project-list');
        }),
    delete: publicProcedure
        .input(z.string({ description: 'Project name' }))
        .mutation(async (opts) => {
            await deleteProject(opts.input);
            cache.invalidate('project-list');
        }),
    open: publicProcedure
        .input(z.object({ name: z.string(), version: z.number() }))
        .query(async opts => {
            const project = await loadProject(opts.input.name, opts.input.version);
            return project;
        }),
    updateConfig: publicProcedure
        .input(ProjectInfo)
        .mutation(async opts => {
            await updateConfig(opts.input.name, opts.input.version, opts.input);
        })
})
