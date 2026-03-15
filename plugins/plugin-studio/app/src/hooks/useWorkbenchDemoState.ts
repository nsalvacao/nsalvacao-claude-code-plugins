import { useEffect, useRef, useState } from 'react';
import {
  DEMO_DOCUMENTS,
  DEMO_TREE_GROUPS,
  DEMO_VALIDATION_ISSUES,
  countDocumentsByGroup,
  getDemoDocumentById,
  getDemoDocumentsByGroup,
  matchesDemoFilter,
  toActiveDocumentInfo,
} from '../lib/workbench-demo.ts';
import type {
  ActiveDocumentInfo,
  ActivePluginInfo,
  AiChatMessage,
  CommandPaletteAction,
  DemoDocument,
  DemoDocumentGroup,
  ToastMessage,
  ValidationIssueDemo,
} from '../types/studio.ts';

const INITIAL_FILE_ID = 'blueprint-maturation.md';
const INITIAL_OPEN_TABS = ['blueprint-maturation.md', 'open.md'];

const EMPTY_DOCUMENT: ActiveDocumentInfo = {
  path: null,
  relativePath: null,
  name: 'No file selected',
  componentType: null,
  language: null,
  dirty: false,
  documentState: 'clean',
  validationSummary: null,
};

function createId(prefix: string) {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function getInitialChatMessages(): AiChatMessage[] {
  return [
    {
      id: createId('ai'),
      role: 'assistant',
      text: 'Session active. I am tracking the workbench context and can help review the current component.',
    },
    {
      id: createId('user'),
      role: 'user',
      text: 'Can you review the structure alignment before we wire the real APIs?',
    },
    {
      id: createId('ai'),
      role: 'assistant',
      text: 'Yes. The shell anatomy is already sound. The next gains come from coherent state wiring, not from adding more chrome.',
    },
  ];
}

function getAssistantReply(document: DemoDocument | null, prompt: string) {
  if (!document) {
    return `I can help, but I need an active component first. Open a file from the tree and I will answer in that context.`;
  }

  const trimmedPrompt = prompt.trim();

  switch (document.group) {
    case 'manifest':
      return `For ${document.fileName}, I would tighten schema validation first. Manifest health should stay separate from dirty editor state.`;
    case 'commands':
      return `For ${document.fileName}, I would keep the command contract lean and make the preview explain behavior without duplicating implementation details.`;
    case 'skills':
      return `In ${document.fileName}, the strongest opportunity is clarifying the sequence and tightening the promises each step makes.`;
    case 'agents':
      return `For ${document.fileName}, I would focus on model choice, frontmatter completeness and the minimum safe prompt surface.`;
    case 'hooks':
      return `For ${document.fileName}, the safest next step is to preserve wrapper schema compliance and make command strings explicit and parseable.`;
    case 'mcp':
      return `For ${document.fileName}, I would make the runtime contract more visible: readiness, capability scope and failure handling.`;
    default:
      return `For ${document.fileName}, I would keep the UI calm and make ${trimmedPrompt || 'the current action'} feel deterministic and operational.`;
  }
}

export function useWorkbenchDemoState(activePlugin: ActivePluginInfo) {
  const [activeFileId, setActiveFileId] = useState<string | null>(INITIAL_FILE_ID);
  const [openTabs, setOpenTabs] = useState<string[]>(INITIAL_OPEN_TABS);
  const [treeFilter, setTreeFilter] = useState('');
  const [commandPaletteOpen, setCommandPaletteOpen] = useState(false);
  const [toasts, setToasts] = useState<ToastMessage[]>([]);
  const [chatMessages, setChatMessages] = useState<AiChatMessage[]>(getInitialChatMessages);
  const [validationIssues] = useState<ValidationIssueDemo[]>(DEMO_VALIDATION_ISSUES);
  const timeoutIdsRef = useRef<number[]>([]);

  useEffect(() => () => {
    timeoutIdsRef.current.forEach((timeoutId) => window.clearTimeout(timeoutId));
  }, []);

  const activeDemoDocument = activeFileId ? getDemoDocumentById(activeFileId) : null;
  const activeDocument = activeDemoDocument
    ? toActiveDocumentInfo(activePlugin, activeDemoDocument)
    : EMPTY_DOCUMENT;

  const visibleDocuments = DEMO_DOCUMENTS.filter((document) => matchesDemoFilter(document, treeFilter));
  const visibleGroups = DEMO_TREE_GROUPS.filter((group) =>
    visibleDocuments.some((document) => document.group === group.id),
  );
  const openTabDocuments = openTabs
    .map((tabId) => DEMO_DOCUMENTS.find((document) => document.id === tabId) ?? null)
    .filter((document): document is DemoDocument => document !== null);

  function dismissToast(toastId: string) {
    setToasts((previous) => previous.filter((toast) => toast.id !== toastId));
  }

  function pushToast(message: string, tone: ToastMessage['tone'] = 'info') {
    const toastId = createId('toast');
    setToasts((previous) => [...previous, { id: toastId, tone, message }]);
    const timeoutId = window.setTimeout(() => {
      dismissToast(toastId);
    }, 3_000);
    timeoutIdsRef.current.push(timeoutId);
  }

  function ensureTab(fileId: string) {
    setOpenTabs((previous) => (previous.includes(fileId) ? previous : [...previous, fileId]));
  }

  function selectFile(fileId: string) {
    ensureTab(fileId);
    setActiveFileId(fileId);
  }

  function selectGroup(groupId: DemoDocumentGroup) {
    const groupDocuments = getDemoDocumentsByGroup(groupId);
    if (groupDocuments.length === 0) return;

    const matchingVisibleDocument = visibleDocuments.find((document) => document.group === groupId);
    selectFile((matchingVisibleDocument ?? groupDocuments[0]).id);
  }

  function closeTab(fileId: string) {
    const nextTabs = openTabs.filter((tabId) => tabId !== fileId);
    setOpenTabs(nextTabs);
    setActiveFileId((currentActiveFileId) => (
      currentActiveFileId !== fileId ? currentActiveFileId : (nextTabs[nextTabs.length - 1] ?? null)
    ));
  }

  function revealActiveFile() {
    if (!activeDemoDocument) return;
    pushToast(`Revealed ${activeDemoDocument.fileName} in the tree.`, 'success');
  }

  function openCommandPalette() {
    setCommandPaletteOpen(true);
  }

  function closeCommandPalette() {
    setCommandPaletteOpen(false);
  }

  function toggleCommandPalette() {
    setCommandPaletteOpen((previous) => !previous);
  }

  function runValidationDemo() {
    pushToast('Running workspace validation…', 'success');
  }

  function sendAiDemoMessage(prompt: string) {
    const trimmedPrompt = prompt.trim();
    if (!trimmedPrompt) return;

    const nextMessages: AiChatMessage[] = [
      {
        id: createId('user'),
        role: 'user',
        text: trimmedPrompt,
      },
      {
        id: createId('ai'),
        role: 'assistant',
        text: getAssistantReply(activeDemoDocument, trimmedPrompt),
      },
    ];

    setChatMessages((previous) => [...previous, ...nextMessages]);
  }

  function triggerAiLens() {
    if (!activeDemoDocument) return;

    setChatMessages((previous) => [
      ...previous,
      {
        id: createId('user'),
        role: 'user',
        text: `Review the highlighted context in ${activeDemoDocument.fileName}.`,
      },
      {
        id: createId('ai'),
        role: 'assistant',
        text: `I would start by tightening the highlighted line in ${activeDemoDocument.fileName} so the shell communicates the next safe action immediately.`,
      },
    ]);
    pushToast(`Context sent to Nexo from ${activeDemoDocument.fileName}.`, 'success');
  }

  const commandPaletteActions: CommandPaletteAction[] = [
    { id: 'open-active-file', label: 'Open active file in split mode', category: 'file', keywords: ['file', 'split'] },
    { id: 'toggle-ai-panel', label: 'Toggle AI rail', category: 'panel', keywords: ['ai', 'assistant', 'rail'] },
    { id: 'toggle-validation', label: 'Toggle validation rail', category: 'panel', keywords: ['validation', 'quality'] },
    { id: 'cycle-tree', label: 'Cycle tree mode', category: 'view', keywords: ['tree', 'compact', 'hide'] },
    { id: 'switch-preview', label: 'Switch to preview mode', category: 'view', keywords: ['preview', 'reading'] },
    { id: 'switch-split', label: 'Switch to split mode', category: 'view', keywords: ['split', 'editor'] },
  ];

  return {
    activeDemoDocument,
    activeDocument,
    activeGroupId: activeDemoDocument?.group ?? null,
    commandPaletteActions,
    commandPaletteOpen,
    documents: DEMO_DOCUMENTS,
    openTabs,
    openTabDocuments,
    chatMessages,
    treeFilter,
    toasts,
    validationIssues,
    visibleDocuments,
    visibleGroups,
    countsByGroup: Object.fromEntries(
      DEMO_TREE_GROUPS.map((group) => [group.id, countDocumentsByGroup(group.id)]),
    ) as Record<DemoDocumentGroup, number>,
    closeTab,
    closeCommandPalette,
    openCommandPalette,
    pushToast,
    revealActiveFile,
    runValidationDemo,
    selectFile,
    selectGroup,
    sendAiDemoMessage,
    setTreeFilter,
    toggleCommandPalette,
    triggerAiLens,
  };
}
