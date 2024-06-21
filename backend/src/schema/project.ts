import { z } from 'zod';
import { RootClip } from './clip';
import { Pool } from './pool';
import { int, sqliteTable, text } from 'drizzle-orm/sqlite-core';

export const projects = sqliteTable('projects', {
    name: text('name').primaryKey(),
    tempo: int('tempo').notNull().default(120),
    time: int('time').notNull().default(0),
    version: int('version').notNull().default(0),
    music: text('music').notNull(), // File name
});

export const ProjectInfo = z.object({
    name: z.string(),
    tempo: z.number(),
    time: z.number(),
    version: z.number(),
    musicFile: z.optional(z.string({ description: 'URI data string' })),
    roots: z.array(RootClip),
    pools: z.array(Pool)
}).default({
    name: '',
    tempo: 120,
    time: 0,
    version: 0,
    musicFile: '',
    roots: [],
    pools: []
});

export const Project = z.object({
    info: ProjectInfo,
})
