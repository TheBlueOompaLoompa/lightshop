import { sqliteTable, text  } from "drizzle-orm/sqlite-core";
import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { projects } from "./project";

export const pools = sqliteTable('pools', {
    project: text('project').references(() => projects.name, { onDelete: 'cascade', onUpdate: 'cascade' }),
    name: text('name').notNull(),
});

export const insertPool = createInsertSchema(pools);
export const selectPool = createSelectSchema(pools);
