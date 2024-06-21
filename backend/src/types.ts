import type { z } from 'zod';
import { Project as ProjectSchema, ProjectInfo as InfoSchema } from '$schema/project';
import { Settings as SettingsSchema, RenderTarget as RenderTargetSchema } from '$schema/settings';

export type Project = z.infer<typeof ProjectSchema>;
export type ProjectInfo = z.infer<typeof InfoSchema>;

export type Settings = z.infer<typeof SettingsSchema>;
export type RenderTarget = z.infer<typeof RenderTargetSchema>;
