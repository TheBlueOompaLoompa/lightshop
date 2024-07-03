import { z } from 'zod';
import { TargetType } from './settings';
import { blob, integer, sqliteTable, text, type AnySQLiteColumn } from 'drizzle-orm/sqlite-core';
import { pools } from './pool';
import { createInsertSchema } from 'drizzle-zod';

export const ParameterType = z.enum(['color', 'number', 'bool']);

export const Parameter = z.object({
    name: z.string(),
    type: ParameterType,
    value: z.union([z.string(), z.number(), z.boolean()]),
});

export const Effect = z.object({
    name: z.string(),
    params: z.array(Parameter),
});

export const ClipType = z.enum(['builtin', 'root', 'composite'])

export const clips = sqliteTable('clips', {
    id: integer('id').primaryKey({ autoIncrement: true }),
    name: text('name').notNull(),
    type: text('type', { enum: ClipType.options }).notNull(),
    targetType: text('target-type', { enum: TargetType.options }).notNull(),
    effects: text('effects', { mode: 'json' }).notNull().default([]).$type<(z.infer<typeof Effect>)[]>(),
    project: text('project'),

    parent: integer('parent').references((): AnySQLiteColumn => clips.id, { onUpdate: 'cascade', onDelete: 'cascade' }),
    pool: text('pool').references(() => pools.name),
    start: integer('start').notNull().default(0),
    end: integer('end').notNull().default(4),
});

export const apiClip = createInsertSchema(clips, {
    type: ClipType,
    targetType: TargetType,
    effects: z.array(Effect)
});
export const betterApiClip = createInsertSchema(clips);

export const apiInsertClip = apiClip.omit({ id: true });
export const betterApiInsertClip = createInsertSchema(clips).omit({ id: true });

const SBaseTreeClip = z.object({
    id: z.number(),
    name: z.string(),
    effects: z.array(Effect),
    start: z.number(),
    end: z.number(),
    type: ClipType,
});

export type TreeClip = z.infer<typeof SBaseTreeClip> & {
    children: TreeClip[];
};

export const STreeClip: z.ZodType<TreeClip> = SBaseTreeClip.extend({
    children: z.lazy(() => STreeClip.array())
});
