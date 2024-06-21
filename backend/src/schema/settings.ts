import { z } from 'zod';

export const TargetType = z.enum(['linear', 'spatial']);

export const Vec3 = z.object({
    x: z.number(),
    y: z.number(),
    z: z.number()
}).default({ x: 0, y: 0, z: 0 });

export const RenderTarget = z.object({
    name: z.string(),
    address: z.string(),
    type: TargetType,
    ledCount: z.number(),
    ledPositions: z.optional(z.array(Vec3))
});

export const Settings = z.object({
    targets: z.array(RenderTarget)
}).default({
    targets: []
});
