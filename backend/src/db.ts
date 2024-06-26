import { drizzle } from "drizzle-orm/bun-sqlite";
import { Database } from "bun:sqlite";
import { migrate } from "drizzle-orm/bun-sqlite/migrator";

const disk = new Database("lightshop.db");
export const diskDB = drizzle(disk);

disk.exec("PRAGMA journal_mode = WAL;");

