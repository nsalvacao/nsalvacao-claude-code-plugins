import type {
  ActiveDocumentInfo,
  ActivePluginInfo,
  ServerStatus,
  StudioLayoutState,
  ValidationIssueDemo,
} from '../../types/studio.ts';

interface StatusStripProps {
  serverStatus: ServerStatus;
  activePlugin: ActivePluginInfo;
  activeDocument: ActiveDocumentInfo;
  validationIssues: ValidationIssueDemo[];
  layout: StudioLayoutState;
  onOpenValidation: () => void;
  onRuntimeClick: () => void;
  onVersionClick: () => void;
}

export function StatusStrip({
  serverStatus,
  activePlugin,
  activeDocument,
  validationIssues,
  layout,
  onOpenValidation,
  onRuntimeClick,
  onVersionClick,
}: StatusStripProps) {
  const versionLabel = serverStatus.version ? `v${serverStatus.version}` : 'v?';
  const validationLabel = validationIssues.length === 0
    ? '0 Issues'
    : validationIssues.length === 1
      ? '1 Issue'
      : `${validationIssues.length} Issues`;
  const validationTone = validationIssues.some((issue) => issue.severity === 'error')
    ? 'error'
    : validationIssues.length > 0
      ? 'warning'
      : 'success';

  return (
    <footer className="status-strip">
      <div className="status-row">
        <div className="status-group">
          <button
            type="button"
            className="status-chip interactive"
            onClick={onRuntimeClick}
          >
            <span className="chip-indicator" />
            <span className="chip-label">RUNTIME</span>
            <span className={`chip-val text-${serverStatus.connection === 'connected' ? 'success' : 'warning'}`}>
              {serverStatus.connection === 'connected' ? 'Connected' : 'Disconnected'}
            </span>
          </button>
          <div className="status-chip">
            <span className="chip-label">PLUGIN</span>
            <span className="chip-val">{activePlugin.displayName}</span>
          </div>
          <div className="status-chip">
            <span className="chip-label">FILE</span>
            <span className="chip-val truncate" style={{ maxWidth: 200 }}>
              {activeDocument.relativePath ?? 'None'}
            </span>
          </div>
        </div>
        <div className="status-group">
          <div className="status-chip">
            <span className="chip-label">MODE</span>
            <span className="chip-val uppercase">{layout.workspaceMode}</span>
          </div>
          <div className="status-chip">
            <span className="chip-label">AI CONTEXT</span>
            <span className="chip-val text-success">Active</span>
          </div>
        </div>
      </div>

      <div className="status-row">
        <div className="status-group">
          <button
            type="button"
            className="status-chip interactive"
            onClick={onOpenValidation}
          >
            <span className="chip-label">VALIDATION</span>
            <span className={`chip-val text-${validationTone}`}>{validationLabel}</span>
          </button>
          <div className="status-chip">
            <span className="chip-label">ENCODING</span>
            <span className="chip-val">UTF-8</span>
          </div>
        </div>
        <div className="status-group">
          <div className="status-chip">
            <span className="chip-label">CURSOR</span>
            <span className="chip-val">Ln 1, Col 1</span>
          </div>
          <button
            type="button"
            className="status-chip interactive"
            onClick={onVersionClick}
          >
            <span className="chip-label">VERSION</span>
            <span className="chip-val">{versionLabel}</span>
          </button>
        </div>
      </div>
    </footer>
  );
}
