import { writable } from "svelte/store";
import { Invalidations } from "./types";
import type { CreateTRPCClient } from "@trpc/client";
import type { AppRouter } from "@backend/index";

export const Invalidate = writable<Invalidations>(Invalidations.None);
export const Client = writable<CreateTRPCClient<AppRouter>>();
