import type { DemoDocument } from '../../types/studio.ts';

interface EditorTabsProps {
  activeFileId: string | null;
  documents: DemoDocument[];
  onClose: (documentId: string) => void;
  onSelect: (documentId: string) => void;
}

export function EditorTabs({
  activeFileId,
  documents,
  onClose,
  onSelect,
}: EditorTabsProps) {
  return (
    <div className="editor-tabs" role="tablist" aria-label="Open documents">
      {documents.map((document) => (
        <div
          key={document.id}
          role="tab"
          className={`editor-tab ${activeFileId === document.id ? 'active' : ''}`}
          aria-selected={activeFileId === document.id}
          tabIndex={0}
          onClick={() => onSelect(document.id)}
          onKeyDown={(event) => {
            if (event.key === 'Enter' || event.key === ' ') {
              event.preventDefault();
              onSelect(document.id);
            }
          }}
        >
          <span className="tab-icon" style={{ color: `var(--accent-${document.tabTone ?? 'cyan'})` }}>📄</span>
          <span>{document.fileName}</span>
          
          <span
            role="button"
            className="tab-close"
            onClick={(event) => {
              event.stopPropagation();
              onClose(document.id);
            }}
          >
            ×
          </span>
        </div>
      ))}
    </div>
  );
}
