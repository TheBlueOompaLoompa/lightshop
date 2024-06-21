import { Settings } from "$schema/settings";
import { publicProcedure } from "../trpc";
import { router } from "../trpc";

const SETTINGS_FILE = './settings.json';

export default router({
    load: publicProcedure
        .query(async opts => {
            try {
                const file = await Bun.file(SETTINGS_FILE).json();
                return Settings.parse(file);
            }catch {
                return Settings.parse(undefined);
            }
        }),
    save: publicProcedure
        .input(Settings)
        .mutation(opts => {
            const file = Bun.file(SETTINGS_FILE);
            const writer = file.writer()
            writer.write(JSON.stringify(opts.input));
            writer.end();
        })
});
