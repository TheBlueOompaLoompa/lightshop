import { router, createCallerFactory } from './trpc';
import { createBunWSHandler, type CreateBunContextOptions } from 'trpc-bun-adapter';
import projects from '$api/projects';
import settings from '$api/settings';
import type { Project } from 'types';
import { resolve } from 'node:path';

const appRouter = router({
    projects,
    settings
});

const createCaller = createCallerFactory(appRouter);
const caller = createCaller({});

export const createContext = (opts: CreateBunContextOptions) => ({
});

const FRONTEND_PATH = resolve('../frontend/build/');

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
