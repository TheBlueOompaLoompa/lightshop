import { real, sqliteTable, text } from "drizzle-orm/sqlite-core";
import { projects } from "./project";
import { createInsertSchema } from "drizzle-zod";

export const bpms = sqliteTable('bpm', {
    project: text('project').references(() => projects.name, { onDelete: 'cascade', onUpdate: 'cascade' }).notNull(),
    bpm: real('bpm').notNull(),
    beat: real('beat').notNull(),
});

export const insertBpm = createInsertSchema(bpms);
