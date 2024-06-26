import { z } from "zod";
import { apiClip } from "@backend/schema/clip";
import { insertBpm } from "@backend/schema/bpm";

export enum Invalidations {
    None,
    ProjectList,
}

export const SClipItem = z.object({
    type: z.literal('clip'),
    clip: apiClip
});

export const SBpmItem = z.object({
    type: z.literal('bpm'),
    bpm: insertBpm
});

export const SCursorBasket = z.optional(z.discriminatedUnion('type', [
    SClipItem,
    SBpmItem
]));

export type CursorBasket = z.infer<typeof SCursorBasket>;
export type ClipItem = z.infer<typeof SClipItem>;
export type BpmItem = z.infer<typeof SBpmItem>;
