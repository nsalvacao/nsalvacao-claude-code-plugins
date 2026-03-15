import type { ActiveDocumentInfo, ValidationIssueDemo } from '../../../types/studio.ts';

interface ValidationPlaceholderProps {
  activeDocument: ActiveDocumentInfo;
  issues: ValidationIssueDemo[];
  onSelectIssue: (issue: ValidationIssueDemo) => void;
}

export function ValidationPlaceholder({
  activeDocument,
  issues,
  onSelectIssue,
}: ValidationPlaceholderProps) {
  const errorIssues = issues.filter((issue) => issue.severity === 'error');
  const warningIssues = issues.filter((issue) => issue.severity === 'warning');

  return (
    <>
      <div style={{ padding: '16px 16px 0', opacity: 0.7, fontSize: 13, display: 'flex', gap: 24 }}>
        <div>
          <p style={{ margin: 0, fontWeight: 700, fontSize: 10, textTransform: 'uppercase', letterSpacing: '0.1em' }}>Validation backend</p>
          <p style={{ margin: '4px 0 0' }}>Native validation routes are live. Shaping the final operator experience.</p>
        </div>
        <div>
          <span style={{ fontWeight: 700, fontSize: 10, textTransform: 'uppercase', letterSpacing: '0.1em' }}>Active document</span>
          <div style={{ margin: '4px 0 0' }}><strong>{activeDocument.name}</strong> • {activeDocument.validationSummary ?? '0 Issues'}</div>
        </div>
      </div>

      <div style={{ marginTop: 16 }}>
        <div className="val-group-header">Errors ({errorIssues.length})</div>
        {errorIssues.map((issue) => (
          <button
            key={issue.id}
            type="button"
            className="val-item"
            data-severity={issue.severity}
            onClick={() => onSelectIssue(issue)}
          >
            <span className="val-type err">ERROR</span>
            <span className="val-msg">{issue.message}</span>
            <span className="val-loc">{issue.location}</span>
          </button>
        ))}

        <div className="val-group-header">Warnings ({warningIssues.length})</div>
        {warningIssues.map((issue) => (
          <button
            key={issue.id}
            type="button"
            className="val-item"
            data-severity={issue.severity}
            onClick={() => onSelectIssue(issue)}
          >
            <span className="val-type wrn">WARNING</span>
            <span className="val-msg">{issue.message}</span>
            <span className="val-loc">{issue.location}</span>
          </button>
        ))}
      </div>
    </>
  );
}
