export type ServerConnectionState = 'checking' | 'connected' | 'disconnected';
export type TreePanelMode = 'expanded' | 'compact' | 'collapsed';
export type WorkspaceViewMode = 'edit' | 'preview' | 'split';
export type StatusTone = 'neutral' | 'success' | 'warning' | 'danger' | 'info';
export type DemoDocumentGroup = 'manifest' | 'commands' | 'skills' | 'agents' | 'hooks' | 'mcp' | 'config';
export type DemoDocumentState = 'clean' | 'modified' | 'validation-issues';
export type PreviewBlockKind = 'heading1' | 'heading2' | 'paragraph' | 'code' | 'list';
export type PreviewBlockTone = 'default' | 'warning' | 'danger';
export type EditorLineTone = 'default' | 'comment' | 'keyword' | 'prop' | 'string';
export type ToastTone = 'info' | 'success' | 'warning';
export type ChatRole = 'assistant' | 'user';

export interface ServerStatus {
  connection: ServerConnectionState;
  version: string | null;
  note: string | null;
  checkedAt: number | null;
}

export interface StudioLayoutState {
  leftMode: TreePanelMode;
  leftWidth: number;
  centerSplit: number;
  rightOpen: boolean;
  bottomOpen: boolean;
  bottomHeight: number;
  workspaceMode: WorkspaceViewMode;
}

export interface ActivePluginInfo {
  rootPath: string | null;
  displayName: string;
}

export interface ActiveDocumentInfo {
  path: string | null;
  relativePath: string | null;
  name: string;
  componentType: string | null;
  language: string | null;
  dirty: boolean;
  documentState: DemoDocumentState;
  validationSummary: string | null;
}

export interface BreadcrumbItem {
  label: string;
  current?: boolean;
}

export interface StatusStripItem {
  id: string;
  label: string;
  value: string;
  note: string;
  tone?: StatusTone;
  interactive?: boolean;
}

export interface StatusBarModel {
  primary: StatusStripItem[];
  secondary: StatusStripItem[];
}

export interface EditorLine {
  text: string;
  tone?: EditorLineTone;
  lens?: boolean;
}

export interface PreviewBlock {
  kind: PreviewBlockKind;
  text?: string;
  items?: string[];
  tone?: PreviewBlockTone;
}

export interface DemoDocument {
  id: string;
  fileName: string;
  relativePath: string;
  group: DemoDocumentGroup;
  componentType: string;
  language: string;
  documentState: DemoDocumentState;
  validationSummary: string;
  dirty: boolean;
  tabTone: 'amber' | 'cyan' | 'olive' | 'warning' | 'danger';
  editorLines: EditorLine[];
  preview: PreviewBlock[];
  aiContextNote: string;
}

export interface DemoTreeGroup {
  id: DemoDocumentGroup;
  label: string;
  sigil: string;
  tone: 'amber' | 'cyan' | 'olive';
}

export interface ValidationIssueDemo {
  id: string;
  severity: 'error' | 'warning';
  message: string;
  location: string;
  targetFileId: string;
}

export interface AiChatMessage {
  id: string;
  role: ChatRole;
  text: string;
}

export interface ToastMessage {
  id: string;
  tone: ToastTone;
  message: string;
}

export interface CommandPaletteAction {
  id: string;
  label: string;
  category: 'file' | 'view' | 'panel' | 'utility';
  keywords?: string[];
}
