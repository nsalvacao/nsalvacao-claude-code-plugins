import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  DEFAULT_AI_PROVIDER_ORDER,
  DEFAULT_GEMINI_MODEL,
  DEFAULT_GITHUB_MODELS_API_URL,
} from './provider.types.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const REPO_ROOT = path.resolve(__dirname, '../../../../../');
const DEFAULT_DEV_ENV_PATH = path.join(REPO_ROOT, '.dev', '.env');

function stripWrappingQuotes(value) {
  if (
    (value.startsWith('"') && value.endsWith('"'))
    || (value.startsWith('\'') && value.endsWith('\''))
  ) {
    return value.slice(1, -1);
  }

  return value;
}

function parseEnvFile(filePath) {
  try {
    const raw = fs.readFileSync(filePath, 'utf8');
    const parsed = {};

    for (const line of raw.split(/\r?\n/)) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const match = trimmed.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/);
      if (!match) continue;
      parsed[match[1]] = stripWrappingQuotes(match[2].trim());
    }

    return parsed;
  } catch {
    return {};
  }
}

function readValue(parsedFileEnv, key) {
  const processValue = process.env[key];
  if (typeof processValue === 'string' && processValue.trim()) {
    return processValue.trim();
  }

  const fileValue = parsedFileEnv[key];
  return typeof fileValue === 'string' && fileValue.trim() ? fileValue.trim() : null;
}

export function getAiProviderPreference() {
  return {
    order: [...DEFAULT_AI_PROVIDER_ORDER],
    defaultProvider: DEFAULT_AI_PROVIDER_ORDER[0],
  };
}

export function getAiProviderConfig(options = {}) {
  const envFilePath = options.envFilePath ?? process.env.PLUGIN_STUDIO_AI_ENV_FILE ?? DEFAULT_DEV_ENV_PATH;
  const parsedFileEnv = parseEnvFile(envFilePath);

  return {
    githubModelsToken: readValue(parsedFileEnv, 'GITHUB_MODELS_TOKEN'),
    githubModelsModel: readValue(parsedFileEnv, 'GITHUB_MODELS_MODEL'),
    githubModelsApiUrl: readValue(parsedFileEnv, 'GITHUB_MODELS_API_URL') ?? DEFAULT_GITHUB_MODELS_API_URL,
    geminiApiKey: readValue(parsedFileEnv, 'GEMINI_API_KEY'),
    geminiModel: readValue(parsedFileEnv, 'GEMINI_MODEL') ?? DEFAULT_GEMINI_MODEL,
  };
}
