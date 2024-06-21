import { drizzle } from "drizzle-orm/bun-sqlite";
import { Database } from "bun:sqlite";

const disk = new Database("lightshop.db");
const memory = new Database(":memory:");
export const diskDB = drizzle(disk);
export const memDB = drizzle(memory);

