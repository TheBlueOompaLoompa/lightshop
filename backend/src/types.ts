import type { z } from 'zod';
import { insertProject } from '$schema/project';
import { Settings as SettingsSchema, RenderTarget as RenderTargetSchema } from '$schema/settings';
import type { apiClip, Effect as SEffect } from '$schema/clip';
import type { insertPool } from '$schema/pool';
import type { insertBpm } from '$schema/bpm';

export type Project = z.infer<typeof insertProject>;
export type Clip = z.infer<typeof apiClip>;
export type Effect = z.infer<typeof SEffect>;
export type Pool = z.infer<typeof insertPool>;
export type Bpm = z.infer<typeof insertBpm>;

export type Settings = z.infer<typeof SettingsSchema>;
export type RenderTarget = z.infer<typeof RenderTargetSchema>;
