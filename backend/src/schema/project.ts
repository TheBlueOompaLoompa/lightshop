import { int, real, sqliteTable, text } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';

export const projects = sqliteTable('projects', {
    name: text('name').primaryKey(),
    tempo: int('tempo').notNull().default(120),
    time: int('time').notNull().default(0),
    offset: real('offset').notNull().default(0),
    version: int('version').notNull().default(0),
    music: text('music') // Data url
});

export const insertProject = createInsertSchema(projects);
export const selectProject = createSelectSchema(projects);
