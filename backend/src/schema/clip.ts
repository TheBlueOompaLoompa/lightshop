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

export const ClipType = z.enum(['builtin', 'root', 'composite'])

export const clips = sqliteTable('clips', {
    id: integer('id').primaryKey({ autoIncrement: true }),
    name: text('name').notNull(),
    type: text('type', { enum: ClipType.options }).notNull(),
    targetType: text('target-type', { enum: TargetType.options }).notNull(),
    params: text('parameters', { mode: 'json' }).notNull().$type<(z.infer<typeof Parameter>)[]>(),
    project: text('project'),

    parent: integer('parent').references((): AnySQLiteColumn => clips.id, { onUpdate: 'cascade', onDelete: 'cascade' }),
    pool: text('pool').references(() => pools.name),
    start: integer('start').notNull().default(0),
    end: integer('end').notNull().default(4),
});

export const apiClip = createInsertSchema(clips, {
    type: ClipType,
    targetType: TargetType,
    params: z.array(Parameter)
});
export const betterApiClip = createInsertSchema(clips);

export const apiInsertClip = apiClip.omit({ id: true });
export const betterApiInsertClip = createInsertSchema(clips).omit({ id: true });

export interface TreeClip {
    id: number,
    children: TreeClip[]
}
