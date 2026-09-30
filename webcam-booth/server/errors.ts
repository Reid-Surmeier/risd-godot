export type GenerationError = { readonly code: 'invalid' | 'busy' | 'budget' | 'uncertain' | 'unavailable'; readonly message: string };
