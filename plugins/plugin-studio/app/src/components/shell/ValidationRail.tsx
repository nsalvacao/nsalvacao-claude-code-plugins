import type { ActiveDocumentInfo, ValidationIssueDemo } from '../../types/studio.ts';
import { ValidationPlaceholder } from './placeholders/ValidationPlaceholder.tsx';

interface ValidationRailProps {
  activeDocument: ActiveDocumentInfo;
  issues: ValidationIssueDemo[];
  open: boolean;
  height: number;
  onRunAll: () => void;
  onSelectIssue: (issue: ValidationIssueDemo) => void;
  onToggle: () => void;
}

export function ValidationRail({
  activeDocument,
  issues,
  open,
  height,
  onRunAll,
  onSelectIssue,
  onToggle,
}: ValidationRailProps) {
  function handleHeaderKeyDown(event: React.KeyboardEvent<HTMLDivElement>) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      onToggle();
    }
  }

  return (
    <section style={{ height: open ? height : 40 }} className={`validation-rail ${open ? '' : 'collapsed'}`}>
      <div className="val-header" onClick={onToggle} onKeyDown={handleHeaderKeyDown} tabIndex={0} role="button">
        <div className="val-title">
          Validation Summary
          {issues.length > 0 && <span className="val-badge">{issues.length}</span>}
        </div>
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <button
            type="button"
            className="btn-ghost"
            style={{ color: 'var(--accent-cyan)', fontSize: 10 }}
            onClick={(e) => { e.stopPropagation(); onRunAll(); }}
          >
            RUN ALL
          </button>
          <button
            type="button"
            className="btn-ghost"
            style={{ fontSize: 10 }}
            aria-label={open ? 'Collapse' : 'Expand'}
            onClick={(event) => {
              event.stopPropagation();
              onToggle();
            }}
          >
            {open ? 'COLLAPSE' : 'EXPAND'}
          </button>
        </div>
      </div>

      <div className="val-content">
        <ValidationPlaceholder
          activeDocument={activeDocument}
          issues={issues}
          onSelectIssue={onSelectIssue}
        />
      </div>
    </section>
  );
}
