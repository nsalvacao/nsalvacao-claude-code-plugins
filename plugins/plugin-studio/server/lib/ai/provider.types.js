/**
 * @typedef {'github-models' | 'gemini'} AIProviderKind
 */

/**
 * @typedef {{
 *   order: AIProviderKind[],
 *   defaultProvider: AIProviderKind,
 * }} AIProviderPreference
 */

/**
 * @typedef {{
 *   githubModelsToken: string | null,
 *   githubModelsModel: string | null,
 *   githubModelsApiUrl: string,
 *   geminiApiKey: string | null,
 *   geminiModel: string,
 * }} AIProviderConfig
 */

export const AI_PROVIDER_KINDS = ['github-models', 'gemini'];

export const DEFAULT_AI_PROVIDER_ORDER = ['github-models', 'gemini'];

export const DEFAULT_GITHUB_MODELS_API_URL = 'https://models.github.ai/inference/chat/completions';

export const DEFAULT_GEMINI_MODEL = 'gemini-2.5-flash';
