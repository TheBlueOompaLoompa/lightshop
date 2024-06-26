import { router, createCallerFactory } from './trpc';
import { createBunWSHandler, type CreateBunContextOptions } from 'trpc-bun-adapter';
import projects from '$api/projects';
import pools from '$api/pool';
import player from '$api/player';
import settings from '$api/settings';
import { resolve } from 'node:path';
import bpm from '$api/bpm';
import _ from 'lodash';
import animations from 'animations/animations';
import clips from '$api/clips';

const appRouter = router({
    projects,
    pools,
    player,
    clips,
    bpm,
    settings,
});

const createCaller = createCallerFactory(appRouter);
export const caller = createCaller({});

async function setupBuiltin() {
    // Default pools
    const poolList = await caller.pools.list('');
    const linear = { name: 'Linear', project: null };
    const spatial = { name: 'Spatial', project: null };
    if(!_.some(poolList, linear)) await caller.pools.new(linear);
    if(!_.some(poolList, spatial)) await caller.pools.new(spatial);

    // Default clips
    const linearClips = await caller.clips.list({ pool: linear.name });
    const spatialClips = await caller.clips.list({ pool: spatial.name });
    Object.keys(animations).forEach(async anim => {
        if(animations[anim].targets.includes('linear') && !_.some(linearClips, ['name', anim])) {
            await caller.clips.new({
                name: anim,
                type: 'builtin',
                pool: linear.name,
                params: animations[anim].params,
                targetType: 'linear'
            });
        }

        if(animations[anim].targets.includes('spatial') && !_.some(spatialClips, ['name', anim])) {
            await caller.clips.new({
                name: anim,
                type: 'builtin',
                pool: spatial.name,
                params: animations[anim].params,
                targetType: 'spatial'
            });
        }
    });
}

export const createContext = (opts: CreateBunContextOptions) => ({
});

const FRONTEND_PATH = resolve('../frontend/build/');

await setupBuiltin();
Bun.serve({
    fetch(req, server) {
        const url = new URL(req.url);
        if(url.pathname.startsWith('/trpc')) {
            if (server.upgrade(req, {data: { req }})) {
                return;
            }

            return new Response("Please use websocket protocol", {status: 404});
        }else {
            const path = resolve(`${FRONTEND_PATH}/${url.pathname.slice(1)}`);
            if(path.startsWith(FRONTEND_PATH)) {
                const parts = path.split('/');
                if(parts[parts.length - 1] == '' || parts[parts.length - 1] == 'build') return new Response(Bun.file(path + '/index.html'));

                if(!parts[parts.length - 1].includes('.')) return new Response(Bun.file(path + '.html'));

                return new Response(Bun.file(path));
            }
        }
    },
    websocket: createBunWSHandler({
        router: appRouter,
        batching: {
            enabled: true
        },
        createContext
    }),
    port: 3000
});

export type AppRouter = typeof appRouter;
