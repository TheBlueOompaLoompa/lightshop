import { Settings } from "$schema/settings";
import type { Settings as TSettings } from "../types";
import Cache from "cache";
import { publicProcedure } from "../trpc";
import { router } from "../trpc";

const SETTINGS_FILE = './settings.json';

const cache = new Cache();

export default router({
    load: publicProcedure
        .query(async _opts => {
            try {
                const file = await Bun.file(SETTINGS_FILE).json();
                return await cache.useCache('settings', () => Settings.parse(file)) as TSettings;
            }catch {
                return await cache.useCache('settings', () => Settings.parse(undefined)) as TSettings;
            }
        }),
    save: publicProcedure
        .input(Settings)
        .mutation(opts => {
            cache.invalidate('settings');
            const file = Bun.file(SETTINGS_FILE);
            const writer = file.writer()
            writer.write(JSON.stringify(opts.input));
            writer.end();
        })
});
