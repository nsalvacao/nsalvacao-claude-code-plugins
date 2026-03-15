import type { ActiveDocumentInfo } from '../../types/studio.ts';

interface ContextBarProps {
  activeDocument: ActiveDocumentInfo;
}

interface MetaPillProps {
  label: string;
  value: string;
}

function MetaPill({ label, value }: MetaPillProps) {
  return (
    <div className="meta-item">
      <span className="meta-label">{label}</span>
      <span className="meta-value">{value}</span>
    </div>
  );
}

export function ContextBar({ activeDocument }: ContextBarProps) {
  const hasDocument = Boolean(activeDocument.path);
  const stateLabel = activeDocument.documentState === 'validation-issues'
    ? 'Validation issues'
    : activeDocument.documentState === 'modified'
      ? 'Modified'
      : 'Clean';

  return (
    <div>
      <div className="context-info">
        <p className="context-eyebrow">Active component</p>
        <div className="context-title-row">
          <p className="context-title">
            {hasDocument ? activeDocument.name : 'Select a component to begin'}
          </p>
          <p className="context-path">
            {hasDocument
              ? activeDocument.relativePath
              : 'The tree will drive this context bar when issue #6 lands.'}
          </p>
        </div>
      </div>

      <div className="context-meta">
        <MetaPill label="Type" value={activeDocument.componentType ?? 'Awaiting tree'} />
        <MetaPill label="Language" value={activeDocument.language ?? '--'} />
        <MetaPill label="State" value={stateLabel} />
      </div>
    </div>
  );
}
