import type {
  ActiveDocumentInfo,
  ActivePluginInfo,
  BreadcrumbItem,
} from '../types/studio.ts';

function normalizePath(value: string) {
  return value.replace(/\\/g, '/').replace(/\/+$/, '');
}

function basename(value: string) {
  const normalized = normalizePath(value);
  const segments = normalized.split('/').filter(Boolean);
  return segments[segments.length - 1] ?? '';
}

function titleCase(value: string) {
  return value
    .split(/[-_\s]+/)
    .filter(Boolean)
    .map((segment) => segment.charAt(0).toUpperCase() + segment.slice(1))
    .join(' ');
}

function detectComponentType(relativePath: string) {
  const normalized = normalizePath(relativePath);

  if (normalized === '.claude-plugin/plugin.json') return 'Manifest';
  if (normalized.startsWith('commands/')) return 'Command';
  if (normalized.startsWith('skills/')) return 'Skill';
  if (normalized.startsWith('agents/')) return 'Agent';
  if (normalized.startsWith('hooks/')) return 'Hook';
  if (normalized.endsWith('.mcp.json') || normalized === '.mcp.json') return 'MCP';
  if (normalized.startsWith('.claude-plugin/')) return 'Plugin config';

  return 'Document';
}

function detectLanguage(relativePath: string) {
  if (relativePath.endsWith('.md')) return 'Markdown';
  if (relativePath.endsWith('.json')) return 'JSON';
  if (relativePath.endsWith('.yaml') || relativePath.endsWith('.yml')) return 'YAML';
  if (relativePath.endsWith('.sh')) return 'Shell';
  if (relativePath.endsWith('.ts')) return 'TypeScript';
  return 'Plain text';
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

export function getDefaultActiveDocument(activePlugin: ActivePluginInfo): ActiveDocumentInfo {
  if (!activePlugin.rootPath) {
    return {
      path: null,
      relativePath: null,
      name: 'No file selected',
      componentType: null,
      language: null,
      dirty: false,
      documentState: 'clean',
      validationSummary: null,
    };
  }

  const relativePath = 'commands/open.md';
  const normalizedRoot = normalizePath(activePlugin.rootPath);

  return {
    path: `${normalizedRoot}/${relativePath}`,
    relativePath,
    name: basename(relativePath),
    componentType: detectComponentType(relativePath),
    language: detectLanguage(relativePath),
    dirty: false,
    documentState: 'clean',
    validationSummary: '0 Issues',
  };
}

export function getHeaderBreadcrumbs(
  activePlugin: ActivePluginInfo,
  activeDocument: ActiveDocumentInfo,
): BreadcrumbItem[] {
  if (!activePlugin.rootPath) {
    return [
      { label: 'Plugin Studio' },
      { label: 'No plugin loaded', current: true },
    ];
  }

  const breadcrumbs: BreadcrumbItem[] = [
    { label: activePlugin.displayName },
  ];

  if (activeDocument.componentType) {
    breadcrumbs.push({ label: activeDocument.componentType });
  }

  if (activeDocument.relativePath) {
    breadcrumbs.push({ label: activeDocument.name, current: true });
  } else {
    breadcrumbs.push({ label: 'Workbench', current: true });
  }

  return breadcrumbs;
}

export function getContextLabel(activePlugin: ActivePluginInfo, activeDocument: ActiveDocumentInfo) {
  if (!activePlugin.rootPath) return 'Context waiting for /plugin-studio:open';
  if (!activeDocument.relativePath) return `${activePlugin.displayName} loaded`;
  return `${titleCase(activeDocument.componentType ?? 'document')} • ${activeDocument.relativePath}`;
}
