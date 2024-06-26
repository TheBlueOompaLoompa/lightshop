import { migrate } from 'drizzle-orm/bun-sqlite/migrator';
import { diskDB } from './src/db';

// This will run migrations on the database, skipping the ones already applied
migrate(diskDB, { migrationsFolder: './drizzle' });
