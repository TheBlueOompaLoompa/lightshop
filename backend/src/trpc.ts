import { initTRPC } from '@trpc/server';
import type { createContext } from 'index';

const t = initTRPC.context<typeof createContext>().create();

export const { router, createCallerFactory } = t;
export const publicProcedure = t.procedure;
