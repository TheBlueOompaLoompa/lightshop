import { router, createCallerFactory } from './trpc';
import { createBunWSHandler, type CreateBunContextOptions } from 'trpc-bun-adapter';
import projects from '$api/projects';
import pools from '$api/pool';
import player from '$api/player';
import settings from '$api/settings';
import { resolve } from 'node:path';
import bpm from '$api/bpm';
import _ from 'lodash';
import presets from 'animations/presets';
import clips from '$api/clips';
import { TargetType } from '$schema/settings';
import { ClipType } from '$schema/clip';
import type { Clip } from 'types';

const appRouter = router({
    projects,
    pools,
    player,
    clips,
    bpm,
    settings,
});

const createCaller = createCallerFactory(appRouter);
export const caller = createCaller({ id: 0, data: {} });

async function setupBuiltin() {
    // Default pools
    const poolList = await caller.pools.list('');
    const linear = { name: 'Linear', project: null };
    const spatial = { name: 'Spatial', project: null };
    if(!_.some(poolList, linear)) await caller.pools.new(linear);
    if(!_.some(poolList, spatial)) await caller.pools.new(spatial);

    // Repair if numbers somehow become strings
    /*const fixClips = await caller.clips.list({ pool: '', project:  'Rock You' });
    await fixClips.forEach(async (clip: Clip) => {
        if(clip.effects) {
            for(let ei = 0; ei < clip.effects.length; ei++) {
                for(let pi = 0; pi < clip.effects[ei].params.length; pi++) {
                    const param = clip.effects[ei].params[pi];

                    switch(param.type) {
                        case 'color':
                            param.value = `${param.value}`;
                            break;
                        case 'number':
                            if(typeof param.value == 'string') param.value = parseFloat(param.value);
                            break;
                    }
                    
                    clip.effects[ei].params[pi] = param;
                }
            }

            await caller.clips.update(clip);
        }
    });*/

    // Clip Presets
    const linearClips = await caller.clips.list({ pool: linear.name });
    const spatialClips = await caller.clips.list({ pool: spatial.name });
    presets.forEach(async preset => {
        if(preset.targets.includes(TargetType.enum.linear) && !_.some(linearClips, ['name', preset.name])) {
            const clip = {
                name: preset.name,
                type: ClipType.enum.builtin,
                pool: linear.name,
                effects: preset.effects.map(e => ({ name: e.name, params: e.params })),
                targetType: TargetType.enum.linear 
            };
            await caller.clips.new(clip);
        }

        if(preset.targets.includes(TargetType.enum.spatial) && !_.some(spatialClips, ['name', preset.name])) {
            await caller.clips.new({
                name: preset.name,
                type: ClipType.enum.builtin,
                pool: spatial.name,
                effects: preset.effects,
                targetType: TargetType.enum.spatial 
            });
        }
    });
}

interface ContextShape {
    id: number,
    data: any
}

export function createContext(opts: CreateBunContextOptions) {
    const url = new URL(opts.req.url);
    const id = url.searchParams.get('id');

    return {
        id: parseInt(id ?? Date.now().toString()),
        data: {}
    } as ContextShape;
};

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
