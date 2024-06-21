import { z } from "zod";
import { Clip, CompositeClip } from './clip';

export const Pool = z.object({
    name: z.string(),
    clips: z.union([Clip, CompositeClip])
});
