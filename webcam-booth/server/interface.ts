import type { Effect } from 'effect';
import type { GenerationError } from './errors.ts';
export type Capture = { readonly id: string; readonly image: string };
export type Portrait = { readonly image: string; readonly run: string };
export type Generation = (capture: Capture) => Effect.Effect<Portrait, GenerationError>;
