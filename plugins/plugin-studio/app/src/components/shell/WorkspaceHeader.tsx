import type { ActiveDocumentInfo, WorkspaceViewMode } from '../../types/studio.ts';
import { ContextBar } from './ContextBar.tsx';

const VIEW_MODES: WorkspaceViewMode[] = ['edit', 'preview', 'split'];

interface WorkspaceHeaderProps {
  activeDocument: ActiveDocumentInfo;
  workspaceMode: WorkspaceViewMode;
  onReveal: () => void;
  onSetWorkspaceMode: (mode: WorkspaceViewMode) => void;
}

export function WorkspaceHeader({
  activeDocument,
  workspaceMode,
  onReveal,
  onSetWorkspaceMode,
}: WorkspaceHeaderProps) {
  return (
    <div className="context-bar">
      <ContextBar activeDocument={activeDocument} />

      <div className="workspace-controls">
        <div className="mode-switch" role="tablist" aria-label="Workspace mode">
          {VIEW_MODES.map((mode) => (
            <button
              key={mode}
              type="button"
              role="tab"
              aria-selected={workspaceMode === mode}
              className={`mode-btn ${workspaceMode === mode ? 'active' : ''}`}
              onClick={() => onSetWorkspaceMode(mode)}
            >
              {mode}
            </button>
          ))}
        </div>

        <button
          type="button"
          className="btn-ghost"
          onClick={onReveal}
        >
          REVEAL
        </button>
      </div>
    </div>
  );
}
