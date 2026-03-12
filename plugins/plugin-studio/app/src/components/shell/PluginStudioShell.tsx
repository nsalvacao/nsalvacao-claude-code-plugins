import type { PointerEvent as ReactPointerEvent } from 'react';
import { useEffect, useRef, useState } from 'react';
import { useServerStatus } from '../../hooks/useServerStatus.ts';
import { useStudioLayout } from '../../hooks/useStudioLayout.ts';
import { getActivePluginInfo } from '../../lib/plugin-path.ts';
import { PanelFrame } from './PanelFrame.tsx';
import { ResizeHandle } from './ResizeHandle.tsx';
import { StatusBar } from './StatusBar.tsx';
import { StudioHeader } from './StudioHeader.tsx';
import { AiPlaceholder } from './placeholders/AiPlaceholder.tsx';
import { EditorPlaceholder } from './placeholders/EditorPlaceholder.tsx';
import { PreviewPlaceholder } from './placeholders/PreviewPlaceholder.tsx';
import { TreePlaceholder } from './placeholders/TreePlaceholder.tsx';
import { ValidationPlaceholder } from './placeholders/ValidationPlaceholder.tsx';

const KEYBOARD_LEFT_RESIZE_STEP_PX = 16;
const KEYBOARD_CENTER_RESIZE_STEP = 0.02;

export function PluginStudioShell() {
  const serverStatus = useServerStatus();
  const {
    layout,
    updateLeftWidth,
    updateCenterSplit,
    toggleRightPanel,
    toggleBottomPanel,
  } = useStudioLayout();
  const editorPreviewRef = useRef<HTMLDivElement | null>(null);
  const [activePlugin, setActivePlugin] = useState(() => getActivePluginInfo(window.location.search));

  useEffect(() => {
    function syncPluginFromLocation() {
      setActivePlugin(getActivePluginInfo(window.location.search));
    }

    window.addEventListener('popstate', syncPluginFromLocation);
    return () => {
      window.removeEventListener('popstate', syncPluginFromLocation);
    };
  }, []);

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

  return (
    <div className="studio-shell">
      <div className="studio-shell__orb studio-shell__orb--amber" aria-hidden="true" />
      <div className="studio-shell__orb studio-shell__orb--cyan" aria-hidden="true" />

      <StudioHeader
        activePlugin={activePlugin}
        rightOpen={layout.rightOpen}
        onToggleAi={toggleRightPanel}
      />

      <main className="flex min-h-0 flex-1 flex-col px-3 py-3">
        <div className="flex min-h-0 flex-1 flex-col gap-3">
          <div className="flex min-h-0 flex-1 gap-0">
            <aside style={{ width: layout.leftWidth }} className="min-h-0 shrink-0">
              <PanelFrame
                title="Plugin Tree"
                subtitle="Anatomy-first navigation shell for issue #6"
                badge="Issue #6"
                tone="amber"
                bodyClassName="min-h-0 flex-1"
              >
                <TreePlaceholder activePlugin={activePlugin} />
              </PanelFrame>
            </aside>

            <ResizeHandle
              label="Resize plugin tree"
              onPointerDown={startLeftResize}
              valueNow={layout.leftWidth}
              valueMin={220}
              valueMax={420}
              onStep={stepLeftResize}
            />

            <div className="flex min-w-0 flex-1 gap-3">
              <section className="flex min-w-0 flex-1 flex-col gap-3">
                <div ref={editorPreviewRef} className="flex min-h-0 flex-1">
                  <div
                    style={{ width: `${layout.centerSplit * 100}%` }}
                    className="min-w-0 shrink-0"
                  >
                    <PanelFrame
                      title="Editor"
                      subtitle="Split-first shell; Monaco lands next"
                      badge="Issue #7"
                      tone="cyan"
                      bodyClassName="min-h-0 flex-1"
                    >
                      <EditorPlaceholder />
                    </PanelFrame>
                  </div>

                  <ResizeHandle
                    label="Resize editor and preview"
                    onPointerDown={startCenterResize}
                    valueNow={Math.round(layout.centerSplit * 100)}
                    valueMin={35}
                    valueMax={65}
                    onStep={stepCenterResize}
                  />

                  <div className="min-w-0 flex-1">
                    <PanelFrame
                      title="Preview"
                      subtitle="Reading mode placeholder for markdown, JSON and YAML"
                      badge="Issue #8"
                      tone="olive"
                      bodyClassName="min-h-0 flex-1"
                    >
                      <PreviewPlaceholder />
                    </PanelFrame>
                  </div>
                </div>
              </section>

              <aside
                style={{ width: layout.rightOpen ? 320 : 56 }}
                className="min-h-0 shrink-0 transition-[width] duration-200 ease-out"
              >
                {layout.rightOpen ? (
                  <PanelFrame
                    title="AI Assistant"
                    subtitle="Contextual sidebar shell for the v0.2 track"
                    badge="Issue #13"
                    tone="cyan"
                    actions={(
                      <button
                        type="button"
                        className="studio-shell-button"
                        onClick={toggleRightPanel}
                      >
                        COLLAPSE
                      </button>
                    )}
                    bodyClassName="min-h-0 flex-1"
                  >
                    <AiPlaceholder />
                  </PanelFrame>
                ) : (
                  <div className="studio-ai-rail">
                    <button
                      type="button"
                      className="studio-shell-button studio-shell-button--primary rotate-180 [writing-mode:vertical-rl]"
                      onClick={toggleRightPanel}
                    >
                      AI
                    </button>
                  </div>
                )}
              </aside>
            </div>
          </div>

          <section
            style={{ height: layout.bottomOpen ? layout.bottomHeight : 48 }}
            className="shrink-0 transition-[height] duration-200 ease-out"
          >
            {layout.bottomOpen ? (
              <PanelFrame
                title="Validation"
                subtitle="Bottom rail shell for the native validation backend from issue #4"
                badge="Issue #9"
                tone="amber"
                actions={(
                  <button
                    type="button"
                    className="studio-shell-button"
                    onClick={toggleBottomPanel}
                  >
                    COLLAPSE
                  </button>
                )}
                bodyClassName="min-h-0 flex-1"
              >
                <ValidationPlaceholder activePlugin={activePlugin} />
              </PanelFrame>
            ) : (
              <div className="studio-bottom-rail">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.28em] text-[var(--studio-accent-amber)]">
                    Validation rail
                  </p>
                  <p className="mt-1 text-sm text-slate-300">
                    Collapsed shell, ready for issue #9.
                  </p>
                </div>
                <button
                  type="button"
                  className="studio-shell-button studio-shell-button--primary"
                  onClick={toggleBottomPanel}
                >
                  EXPAND
                </button>
              </div>
            )}
          </section>
        </div>
      </main>

      <StatusBar serverStatus={serverStatus} />
    </div>
  );
}
