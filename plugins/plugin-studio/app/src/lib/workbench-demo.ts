import type {
  ActiveDocumentInfo,
  ActivePluginInfo,
  DemoDocument,
  DemoDocumentGroup,
  DemoTreeGroup,
  ValidationIssueDemo,
} from '../types/studio.ts';

export const DEMO_TREE_GROUPS: DemoTreeGroup[] = [
  { id: 'manifest', label: 'Manifest', sigil: 'MF', tone: 'amber' },
  { id: 'commands', label: 'Commands', sigil: 'CM', tone: 'cyan' },
  { id: 'skills', label: 'Skills', sigil: 'SK', tone: 'olive' },
  { id: 'agents', label: 'Agents', sigil: 'AG', tone: 'amber' },
  { id: 'hooks', label: 'Hooks', sigil: 'HK', tone: 'cyan' },
  { id: 'mcp', label: 'MCP Servers', sigil: 'MP', tone: 'olive' },
  { id: 'config', label: 'Config', sigil: 'CF', tone: 'amber' },
];

export const DEMO_DOCUMENTS: DemoDocument[] = [
  {
    id: 'plugin.json',
    fileName: 'plugin.json',
    relativePath: '.claude-plugin/plugin.json',
    group: 'manifest',
    componentType: 'Manifest',
    language: 'JSON',
    documentState: 'validation-issues',
    validationSummary: '1 Error',
    dirty: false,
    tabTone: 'danger',
    aiContextNote: 'Manifest schema, metadata and marketplace readiness.',
    editorLines: [
      { text: '{' },
      { text: '  "schema": "1.0",', tone: 'prop' },
      { text: '  "name": "plugin-studio",', tone: 'prop' },
      { text: '  "version": "",', tone: 'prop', lens: true },
      { text: '  "author": "Nuno Salvacao"', tone: 'prop' },
      { text: '}', tone: 'default' },
    ],
    preview: [
      { kind: 'heading1', text: 'Plugin Manifest' },
      {
        kind: 'paragraph',
        text: 'Central runtime contract for the plugin. The preview rail should make schema drift obvious without overwhelming the workbench.',
      },
      { kind: 'heading2', text: 'Validation' },
      {
        kind: 'paragraph',
        tone: 'danger',
        text: 'Missing required field "version". This document is clean in editor terms, but it still carries a validation error.',
      },
    ],
  },
  {
    id: 'open.md',
    fileName: 'open.md',
    relativePath: 'commands/open.md',
    group: 'commands',
    componentType: 'Command',
    language: 'Markdown',
    documentState: 'clean',
    validationSummary: '0 Issues',
    dirty: false,
    tabTone: 'cyan',
    aiContextNote: 'Command execution, arguments and shell opening flow.',
    editorLines: [
      { text: '---', tone: 'comment' },
      { text: 'description: Open the dashboard shell', tone: 'prop' },
      { text: 'arguments: [path]', tone: 'prop' },
      { text: '---', tone: 'comment' },
      { text: '# Plugin Studio', tone: 'keyword' },
      { text: '' },
      { text: 'This shell becomes the Monaco editor in issue #7.' },
      { text: '' },
      { text: 'Focus for #5:' },
      { text: '- split layout' },
      { text: '- resize behavior', lens: true },
      { text: '- shell chrome' },
    ],
    preview: [
      { kind: 'heading1', text: 'Open Command' },
      {
        kind: 'paragraph',
        text: 'Triggers the workbench to load a plugin path while keeping the shell calm, bounded and ready for a future editor stack.',
      },
      { kind: 'heading2', text: 'Quick Reference' },
      { kind: 'list', items: ['Input: plugin root path', 'Output: hydrated workbench shell', 'Mode: split-aware by default'] },
      {
        kind: 'paragraph',
        text: 'The preview surface is intentionally bounded so longer operational documentation remains comfortable to read.',
      },
    ],
  },
  {
    id: 'settings.md',
    fileName: 'settings.md',
    relativePath: 'commands/settings.md',
    group: 'commands',
    componentType: 'Command',
    language: 'Markdown',
    documentState: 'modified',
    validationSummary: '0 Issues',
    dirty: true,
    tabTone: 'warning',
    aiContextNote: 'Settings command flow and persistent workspace preferences.',
    editorLines: [
      { text: '---', tone: 'comment' },
      { text: 'description: Open plugin settings', tone: 'prop' },
      { text: '---', tone: 'comment' },
      { text: '# Settings', tone: 'keyword' },
      { text: '' },
      { text: 'Configure telemetry, layouts and provider preference order.' },
      { text: '' },
      { text: 'TODO:' },
      { text: '- expose GitHub Models default' },
      { text: '- fallback to Gemini', lens: true },
    ],
    preview: [
      { kind: 'heading1', text: 'Plugin Settings' },
      {
        kind: 'paragraph',
        text: 'Settings are where provider defaults, telemetry, autosave and editor ergonomics become tangible product controls.',
      },
      { kind: 'heading2', text: 'State' },
      {
        kind: 'paragraph',
        tone: 'warning',
        text: 'This file is currently modified. Unsaved work should not be conflated with validation health.',
      },
    ],
  },
  {
    id: 'blueprint-maturation.md',
    fileName: 'blueprint-maturation.md',
    relativePath: 'skills/blueprint-maturation.md',
    group: 'skills',
    componentType: 'Skill',
    language: 'Markdown',
    documentState: 'clean',
    validationSummary: '1 Warning',
    dirty: false,
    tabTone: 'olive',
    aiContextNote: 'Skill structure, prompts, examples and architecture guidance.',
    editorLines: [
      { text: '---', tone: 'comment' },
      { text: 'name: blueprint-maturation', tone: 'prop' },
      { text: 'description: Mature first-draft blueprints', tone: 'prop' },
      { text: '---', tone: 'comment' },
      { text: '# Blueprint Maturation', tone: 'keyword' },
      { text: '' },
      { text: 'Transform first-draft blueprints into production-ready architectural specifications.', lens: true },
      { text: '' },
      { text: '## Workflow' },
      { text: '1. Extract' },
      { text: '2. Intake' },
      { text: '3. Synthesize' },
    ],
    preview: [
      { kind: 'heading1', text: 'Blueprint Maturation' },
      {
        kind: 'paragraph',
        text: 'Transform first-draft blueprints into production-ready architectural specifications through structured analysis and technology validation.',
      },
      { kind: 'heading2', text: 'Quick Reference' },
      { kind: 'paragraph', text: 'Input: Draft blueprint document' },
      { kind: 'paragraph', text: 'Output: Maturation report and vNext structure' },
      { kind: 'heading2', text: 'Workflow Overview' },
      {
        kind: 'list',
        items: [
          'Extract the draft cleanly',
          'Validate critical assumptions',
          'Generate safer next-step options',
        ],
      },
    ],
  },
  {
    id: 'plugin-validator.md',
    fileName: 'plugin-validator.md',
    relativePath: 'agents/plugin-validator.md',
    group: 'agents',
    componentType: 'Agent',
    language: 'Markdown',
    documentState: 'clean',
    validationSummary: '0 Issues',
    dirty: false,
    tabTone: 'amber',
    aiContextNote: 'Agent role, model selection and validation system prompt.',
    editorLines: [
      { text: '---', tone: 'comment' },
      { text: 'name: plugin-validator', tone: 'prop' },
      { text: 'model: sonnet', tone: 'prop' },
      { text: 'color: green', tone: 'prop' },
      { text: '---', tone: 'comment' },
      { text: 'Validate plugin structures and report only actionable issues.', lens: true },
    ],
    preview: [
      { kind: 'heading1', text: 'Plugin Validator Agent' },
      {
        kind: 'paragraph',
        text: 'Dedicated agent for deterministic plugin quality review, with emphasis on frontmatter, manifest and structural correctness.',
      },
      { kind: 'heading2', text: 'Model' },
      { kind: 'paragraph', text: 'Sonnet, inheriting runtime context from the selected plugin.' },
    ],
  },
  {
    id: 'hooks.json',
    fileName: 'hooks.json',
    relativePath: 'hooks/hooks.json',
    group: 'hooks',
    componentType: 'Hook',
    language: 'JSON',
    documentState: 'clean',
    validationSummary: '0 Issues',
    dirty: false,
    tabTone: 'cyan',
    aiContextNote: 'Hook event wiring and wrapper schema compliance.',
    editorLines: [
      { text: '{' },
      { text: '  "hooks": {', tone: 'prop' },
      { text: '    "PreToolUse": [', tone: 'prop' },
      { text: '      { "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate.sh" }', tone: 'string', lens: true },
      { text: '    ]', tone: 'prop' },
      { text: '  }', tone: 'prop' },
      { text: '}' },
    ],
    preview: [
      { kind: 'heading1', text: 'Hook Configuration' },
      {
        kind: 'paragraph',
        text: 'Wrapper-form hook schemas are critical for Claude Code runtime compatibility. This surface should make compliance easy to scan.',
      },
      { kind: 'heading2', text: 'Shape' },
      { kind: 'paragraph', text: 'Root object must contain "hooks", which then groups event arrays such as PreToolUse.' },
    ],
  },
  {
    id: 'obsidian-bridge.ts',
    fileName: 'obsidian-bridge.ts',
    relativePath: 'mcp/obsidian-bridge.ts',
    group: 'mcp',
    componentType: 'MCP Server',
    language: 'TypeScript',
    documentState: 'clean',
    validationSummary: '0 Issues',
    dirty: false,
    tabTone: 'olive',
    aiContextNote: 'MCP runtime bridge, connector health and capability routing.',
    editorLines: [
      { text: 'export async function connectObsidianBridge() {', tone: 'keyword' },
      { text: '  const vault = await resolveVault();', tone: 'default' },
      { text: '  return { vault, status: "ready" };', tone: 'string', lens: true },
      { text: '}' },
    ],
    preview: [
      { kind: 'heading1', text: 'Obsidian Bridge' },
      {
        kind: 'paragraph',
        text: 'MCP bridges should read as operational infrastructure, not as decorative integrations. This panel becomes the future surface for capability metadata.',
      },
    ],
  },
  {
    id: 'CLAUDE.md',
    fileName: 'CLAUDE.md',
    relativePath: '.claude-plugin/CLAUDE.md',
    group: 'config',
    componentType: 'Config',
    language: 'Markdown',
    documentState: 'clean',
    validationSummary: '0 Issues',
    dirty: false,
    tabTone: 'amber',
    aiContextNote: 'Project guidance, operating constraints and repo conventions.',
    editorLines: [
      { text: '# Plugin Studio Guidance', tone: 'keyword' },
      { text: '' },
      { text: 'Keep the shell aesthetically controlled, operationally rich and ready for plugin engineering.', lens: true },
    ],
    preview: [
      { kind: 'heading1', text: 'Workspace Guidance' },
      {
        kind: 'paragraph',
        text: 'This configuration surface anchors the rules, expectations and ergonomics that the shell should embody as the product grows.',
      },
    ],
  },
];

export const DEMO_VALIDATION_ISSUES: ValidationIssueDemo[] = [
  {
    id: 'manifest-version',
    severity: 'error',
    message: 'Missing required field "version" in manifest.',
    location: '.claude-plugin/plugin.json:4',
    targetFileId: 'plugin.json',
  },
  {
    id: 'skill-argument-hint',
    severity: 'warning',
    message: 'Unused argument hint remains in skill intake step.',
    location: 'skills/blueprint-maturation.md:3',
    targetFileId: 'blueprint-maturation.md',
  },
];

function normalizePath(value: string) {
  return value.replace(/\\/g, '/').replace(/\/+$/, '');
}

function joinPluginPath(rootPath: string | null, relativePath: string) {
  if (!rootPath) return relativePath;
  return `${normalizePath(rootPath)}/${relativePath}`;
}

export function getDemoDocumentById(documentId: string) {
  return DEMO_DOCUMENTS.find((document) => document.id === documentId) ?? DEMO_DOCUMENTS[0];
}

export function getDemoDocumentsByGroup(groupId: DemoDocumentGroup) {
  return DEMO_DOCUMENTS.filter((document) => document.group === groupId);
}

export function countDocumentsByGroup(groupId: DemoDocumentGroup) {
  return getDemoDocumentsByGroup(groupId).length;
}

export function matchesDemoFilter(document: DemoDocument, filter: string) {
  if (!filter.trim()) return true;
  const normalizedFilter = filter.trim().toLowerCase();
  const haystack = [
    document.fileName,
    document.relativePath,
    document.componentType,
    document.group,
  ]
    .join(' ')
    .toLowerCase();

  return haystack.includes(normalizedFilter);
}

export function toActiveDocumentInfo(
  activePlugin: ActivePluginInfo,
  document: DemoDocument,
): ActiveDocumentInfo {
  return {
    path: joinPluginPath(activePlugin.rootPath, document.relativePath),
    relativePath: document.relativePath,
    name: document.fileName,
    componentType: document.componentType,
    language: document.language,
    dirty: document.dirty,
    documentState: document.documentState,
    validationSummary: document.validationSummary,
  };
}
