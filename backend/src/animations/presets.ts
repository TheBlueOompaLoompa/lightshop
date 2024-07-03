import type { Clip, Effect } from '../types';
import { TargetType } from '$schema/settings';
import effects from './effects';
import type { z } from 'zod';

export default [
    {
        name: 'Solid',
        targets: [TargetType.enum.linear, TargetType.enum.spatial],
        effects: [
            effects.Solid.effect
        ]
    },
    {
        name: 'Section',
        targets: [TargetType.enum.linear, TargetType.enum.spatial],
        effects: [
            effects.Solid.effect,
            effects.Section.effect,
        ]
    }
] as Preset[];

interface Preset {
    name: string,
    targets: z.infer<typeof TargetType>[]
    effects: Effect[],
}
