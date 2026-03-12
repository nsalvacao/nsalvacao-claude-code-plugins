import type { ActivePluginInfo } from '../types/studio.ts';

function normalizePath(value: string) {
  return value.replace(/\\/g, '/').replace(/\/+$/, '');
}

function basename(value: string) {
  const normalized = normalizePath(value);
  const segments = normalized.split('/').filter(Boolean);
  return segments[segments.length - 1] ?? '';
}

export function getActivePluginInfo(search: string): ActivePluginInfo {
  const params = new URLSearchParams(search);
  const pathValue = params.get('path');

  if (!pathValue || !pathValue.trim()) {
    return {
      rootPath: null,
      displayName: 'No plugin loaded',
    };
  }

  return {
    rootPath: pathValue,
    displayName: basename(pathValue) || 'Loaded plugin',
  };
}
