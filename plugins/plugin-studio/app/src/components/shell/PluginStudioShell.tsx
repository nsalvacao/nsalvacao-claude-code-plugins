import type { PointerEvent as ReactPointerEvent } from 'react';
import { useEffect, useRef, useState } from 'react';
import { useServerStatus } from '../../hooks/useServerStatus.ts';
import { useWorkbenchDemoState } from '../../hooks/useWorkbenchDemoState.ts';
import {
  AI_RAIL_WIDTH,
  COMPACT_LEFT_WIDTH,
  MAX_CENTER_SPLIT,
  MAX_LEFT_WIDTH,
  MIN_CENTER_SPLIT,
  MIN_LEFT_WIDTH,
  useStudioLayout,
} from '../../hooks/useStudioLayout.ts';
import { getActivePluginInfo, getHeaderBreadcrumbs } from '../../lib/plugin-path.ts';
import { AiRail } from './AiRail.tsx';
import { CommandPaletteModal } from './CommandPaletteModal.tsx';
import { EditorTabs } from './EditorTabs.tsx';

import { ResizeHandle } from './ResizeHandle.tsx';
import { StatusStrip } from './StatusStrip.tsx';
import { StudioHeader } from './StudioHeader.tsx';
import { ToastHost } from './ToastHost.tsx';
import { TreeRail } from './TreeRail.tsx';
import { ValidationRail } from './ValidationRail.tsx';
import { WorkspaceHeader } from './WorkspaceHeader.tsx';
import { EditorPlaceholder } from './placeholders/EditorPlaceholder.tsx';
import { PreviewPlaceholder } from './placeholders/PreviewPlaceholder.tsx';

const KEYBOARD_LEFT_RESIZE_STEP_PX = 16;
const KEYBOARD_CENTER_RESIZE_STEP = 0.02;
const MIN_WORKBENCH_WIDTH = 360;

function getAiOpenWidth(viewportWidth: number) {
  return Math.min(320, Math.max(240, viewportWidth * 0.26));
}

export function PluginStudioShell() {
  const serverStatus = useServerStatus();
  const {
    layout,
    setLeftMode,
    cycleLeftMode,
    updateLeftWidth,
    updateCenterSplit,
    setRightPanelOpen,
    toggleRightPanel,
    toggleBottomPanel,
    setWorkspaceMode,
  } = useStudioLayout();
  const editorPreviewRef = useRef<HTMLDivElement | null>(null);
  const [activePlugin, setActivePlugin] = useState(() => getActivePluginInfo(window.location.search));
  const {
    activeDemoDocument,
    activeDocument,
    activeGroupId,
    commandPaletteActions,
    commandPaletteOpen,
    countsByGroup,
    documents,
    openTabDocuments,
    chatMessages,
    treeFilter,
    toasts,
    validationIssues,
    visibleDocuments,
    visibleGroups,
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
  } = useWorkbenchDemoState(activePlugin);
  const breadcrumbs = getHeaderBreadcrumbs(activePlugin, activeDocument);
  const showEditor = layout.workspaceMode !== 'preview';
  const showPreview = layout.workspaceMode !== 'edit';

  useEffect(() => {
    function syncPluginFromLocation() {
      setActivePlugin(getActivePluginInfo(window.location.search));
    }

    window.addEventListener('popstate', syncPluginFromLocation);
    return () => {
      window.removeEventListener('popstate', syncPluginFromLocation);
    };
  }, []);

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
        event.preventDefault();
        toggleCommandPalette();
        return;
      }

      if (event.key === 'Escape' && commandPaletteOpen) {
        event.preventDefault();
        closeCommandPalette();
      }
    }

    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [closeCommandPalette, commandPaletteOpen, toggleCommandPalette]);

  useEffect(() => {
    function enforceResponsiveBounds() {
      const viewportWidth = window.innerWidth;
      const treeWidth = layout.leftMode === 'expanded'
        ? layout.leftWidth
        : layout.leftMode === 'compact'
          ? COMPACT_LEFT_WIDTH
          : 0;
      const aiWidth = layout.rightOpen ? getAiOpenWidth(viewportWidth) : AI_RAIL_WIDTH;
      const availableWidth = viewportWidth - treeWidth - aiWidth - 32;

      if (availableWidth < MIN_WORKBENCH_WIDTH) {
        if (layout.leftMode === 'expanded') {
          setLeftMode('compact');
          return;
        }

        if (layout.rightOpen) {
          setRightPanelOpen(false);
        }
      }
    }

    enforceResponsiveBounds();
    window.addEventListener('resize', enforceResponsiveBounds);
    return () => {
      window.removeEventListener('resize', enforceResponsiveBounds);
    };
  }, [layout.leftMode, layout.leftWidth, layout.rightOpen, setLeftMode, setRightPanelOpen]);

  function startLeftResize(event: ReactPointerEvent<HTMLDivElement>) {
    event.preventDefault();
    const handle = event.currentTarget;
    const startX = event.clientX;
    const startWidth = layout.leftWidth;
    const pointerId = event.pointerId;

    document.body.classList.add('studio-dragging');
    handle.setPointerCapture(pointerId);

    function onPointerMove(moveEvent: PointerEvent) {
      updateLeftWidth(startWidth + (moveEvent.clientX - startX));
    }

    function finishDrag() {
      document.body.classList.remove('studio-dragging');
      handle.removeEventListener('pointermove', onPointerMove);
      handle.removeEventListener('pointerup', finishDrag);
      handle.removeEventListener('pointercancel', finishDrag);

      if (handle.hasPointerCapture(pointerId)) {
        handle.releasePointerCapture(pointerId);
      }
    }

    handle.addEventListener('pointermove', onPointerMove);
    handle.addEventListener('pointerup', finishDrag);
    handle.addEventListener('pointercancel', finishDrag);
  }

  function startCenterResize(event: ReactPointerEvent<HTMLDivElement>) {
    event.preventDefault();
    const handle = event.currentTarget;
    const pointerId = event.pointerId;

    document.body.classList.add('studio-dragging');
    handle.setPointerCapture(pointerId);

    function onPointerMove(moveEvent: PointerEvent) {
      const container = editorPreviewRef.current;
      if (!container) return;

      const bounds = container.getBoundingClientRect();
      updateCenterSplit((moveEvent.clientX - bounds.left) / bounds.width);
    }

    function finishDrag() {
      document.body.classList.remove('studio-dragging');
      handle.removeEventListener('pointermove', onPointerMove);
      handle.removeEventListener('pointerup', finishDrag);
      handle.removeEventListener('pointercancel', finishDrag);

      if (handle.hasPointerCapture(pointerId)) {
        handle.releasePointerCapture(pointerId);
      }
    }

    handle.addEventListener('pointermove', onPointerMove);
    handle.addEventListener('pointerup', finishDrag);
    handle.addEventListener('pointercancel', finishDrag);
  }

  function stepLeftResize(direction: -1 | 1) {
    updateLeftWidth(layout.leftWidth + (direction * KEYBOARD_LEFT_RESIZE_STEP_PX));
  }

  function stepCenterResize(direction: -1 | 1) {
    updateCenterSplit(layout.centerSplit + (direction * KEYBOARD_CENTER_RESIZE_STEP));
  }

  function handleReveal() {
    if (layout.leftMode !== 'expanded') {
      setLeftMode('expanded');
    }
    revealActiveFile();
  }

  function handleAskAi() {
    if (!layout.rightOpen) {
      setRightPanelOpen(true);
    }

    triggerAiLens();
  }

  function handleSelectIssue(issueId: string) {
    const issue = validationIssues.find((candidate) => candidate.id === issueId);
    if (!issue) return;

    selectFile(issue.targetFileId);
    pushToast(`Opened ${issue.location} from validation.`, 'success');
  }

  function handleRunAll() {
    if (!layout.bottomOpen) {
      toggleBottomPanel();
    }
    runValidationDemo();
  }

  function handleCommandAction(actionId: string) {
    switch (actionId) {
      case 'toggle-ai-panel':
        toggleRightPanel();
        pushToast(layout.rightOpen ? 'AI drawer moved back to rail.' : 'AI drawer opened.', 'info');
        return;
      case 'toggle-validation':
        toggleBottomPanel();
        return;
      case 'cycle-tree':
        cycleLeftMode();
        return;
      case 'switch-preview':
        setWorkspaceMode('preview');
        return;
      case 'switch-split':
      case 'open-active-file':
        setWorkspaceMode('split');
        return;
      default:
        pushToast(`Action "${actionId}" is ready for the next phase.`, 'info');
    }
  }

  return (
    <div className="studio-shell">
      <StudioHeader
        activePlugin={activePlugin}
        activeDocument={activeDocument}
        breadcrumbs={breadcrumbs}
        serverStatus={serverStatus}
        leftMode={layout.leftMode}
        rightOpen={layout.rightOpen}
        onCycleTree={cycleLeftMode}
        onOpenCommandPalette={openCommandPalette}
        onToggleAi={toggleRightPanel}
      />

      <main className="studio-main">
          {layout.leftMode === 'collapsed' ? (
            <button
              type="button"
              className="studio-left-edge-trigger"
              onClick={() => setLeftMode('expanded')}
            >
              TREE
            </button>
          ) : (
            <>
              <TreeRail
                activeFileId={activeDemoDocument?.id ?? null}
                activeGroupId={activeGroupId}
                activePlugin={activePlugin}
                countsByGroup={countsByGroup}
                groups={visibleGroups}
                mode={layout.leftMode}
                treeFilter={treeFilter}
                visibleDocuments={visibleDocuments}
                expandedWidth={layout.leftWidth}
                onSelectFile={selectFile}
                onSelectGroup={selectGroup}
                onSetMode={setLeftMode}
                onTreeFilterChange={setTreeFilter}
              />

              {layout.leftMode === 'expanded' ? (
                <ResizeHandle
                  label="Resize plugin tree"
                  onPointerDown={startLeftResize}
                  valueNow={layout.leftWidth}
                  valueMin={MIN_LEFT_WIDTH}
                  valueMax={MAX_LEFT_WIDTH}
                  onStep={stepLeftResize}
                />
              ) : null}
            </>
          )}

          <section className="workbench">
            <WorkspaceHeader
              activeDocument={activeDocument}
              workspaceMode={layout.workspaceMode}
              onReveal={handleReveal}
              onSetWorkspaceMode={setWorkspaceMode}
            />

            <div
              ref={editorPreviewRef}
              className="workbench-content"
              data-mode={layout.workspaceMode}
            >
              {showEditor ? (
                <div
                  style={showPreview ? { width: `${layout.centerSplit * 100}%` } : undefined}
                  className="pane"
                >
                  <div className="pane-header">
                    <span className="pane-title">Editor</span>
                    <span className="pane-badge">Issue #7</span>
                  </div>

                  <EditorTabs
                    activeFileId={activeDemoDocument?.id ?? null}
                    documents={openTabDocuments}
                    onClose={closeTab}
                    onSelect={selectFile}
                  />

                  <EditorPlaceholder
                    document={activeDemoDocument}
                    onAskAi={handleAskAi}
                  />
                </div>
              ) : null}

              {showEditor && showPreview ? (
                <div className="pane-border">
                  <ResizeHandle
                    label="Resize editor and preview"
                    onPointerDown={startCenterResize}
                    valueNow={Math.round(layout.centerSplit * 100)}
                    valueMin={Math.round(MIN_CENTER_SPLIT * 100)}
                    valueMax={Math.round(MAX_CENTER_SPLIT * 100)}
                    onStep={stepCenterResize}
                  />
                </div>
              ) : null}

              {showPreview ? (
                <div className="pane">
                  <div className="pane-header">
                    <span className="pane-title">Preview</span>
                    <span className="pane-badge">Reading mode</span>
                  </div>

                  <PreviewPlaceholder document={activeDemoDocument} />
                </div>
              ) : null}
            </div>
          </section>

          <AiRail
            activeDocument={activeDocument}
            chatMessages={chatMessages}
            document={activeDemoDocument}
            open={layout.rightOpen}
            onSend={(prompt) => {
              if (!layout.rightOpen) {
                setRightPanelOpen(true);
              }
              sendAiDemoMessage(prompt);
            }}
            onToggle={toggleRightPanel}
          />
        </main>

        <ValidationRail
          activeDocument={activeDocument}
          issues={validationIssues}
          open={layout.bottomOpen}
          height={layout.bottomHeight}
          onRunAll={handleRunAll}
          onSelectIssue={(issue) => handleSelectIssue(issue.id)}
          onToggle={toggleBottomPanel}
        />

        <StatusStrip
          serverStatus={serverStatus}
          activePlugin={activePlugin}
          activeDocument={activeDocument}
          validationIssues={validationIssues}
          layout={layout}
          onOpenValidation={() => {
            if (!layout.bottomOpen) {
              toggleBottomPanel();
            }
          }}
          onRuntimeClick={() => {
            pushToast(
              serverStatus.connection === 'connected'
                ? 'Runtime is connected and stable.'
                : serverStatus.connection === 'disconnected'
                  ? 'Runtime is currently offline.'
                  : 'Runtime health check is in progress.',
              serverStatus.connection === 'connected' ? 'success' : 'warning',
            );
          }}
          onVersionClick={() => {
            pushToast('Workbench shell restyle is based on the V1.3 prototype.', 'info');
          }}
        />

      <CommandPaletteModal
        actions={commandPaletteActions}
        documents={documents}
        open={commandPaletteOpen}
        onClose={closeCommandPalette}
        onRunAction={handleCommandAction}
        onSelectFile={selectFile}
      />

      <ToastHost toasts={toasts} />
    </div>
  );
}
