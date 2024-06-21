import { z } from 'zod';
import { TargetType } from './settings';

export const Parameter = z.object({
    name: z.string(),
    type: z.enum(['color', 'number', 'bool']),
    value: z.union([z.string(), z.number(), z.boolean()]),
})

export const Clip = z.object({
    id: z.ostring(),
    name: z.string(),
    type: TargetType,
    parameters: z.map(z.string(), Parameter),

    start: z.number(),
    end: z.number(),
});

export const CompositeClip = Clip.extend({
    clips: z.array(Clip)
});

export const RootClip = CompositeClip.extend({
    target: z.string()
});
