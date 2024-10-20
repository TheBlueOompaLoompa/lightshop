import { writable } from "svelte/store";
import { Invalidations, type CursorBasket } from "./types";
import type { CreateTRPCClient } from "@trpc/client";
import type { AppRouter } from "@backend/index";
import type { Project as TProject } from "@backend/types";

export const Invalidate = writable<Invalidations>(Invalidations.None);
export const Client = writable<CreateTRPCClient<AppRouter>>();
export const FPS = writable(120);
export const OnCursor = writable<CursorBasket>();
export const TimelineHover = writable<{ x: number, y: number} | undefined>()

export const Project = writable<TProject>();
export const Snapping = writable(2);
export const Selected = writable<CursorBasket>();
export const NextStart = writable(0);
export const HoverBeat = writable(0);
