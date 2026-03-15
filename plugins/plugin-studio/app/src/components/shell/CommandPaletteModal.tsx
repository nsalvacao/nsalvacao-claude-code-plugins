import { useEffect, useRef, useState } from 'react';
import type { CommandPaletteAction, DemoDocument } from '../../types/studio.ts';

interface CommandPaletteModalProps {
  actions: CommandPaletteAction[];
  documents: DemoDocument[];
  open: boolean;
  onClose: () => void;
  onRunAction: (actionId: string) => void;
  onSelectFile: (documentId: string) => void;
}

function matchesAction(action: CommandPaletteAction, query: string) {
  if (!query) return true;
  const haystack = [action.label, action.category, ...(action.keywords ?? [])]
    .join(' ')
    .toLowerCase();
  return haystack.includes(query);
}

function matchesDocument(document: DemoDocument, query: string) {
  if (!query) return true;
  const haystack = [
    document.fileName,
    document.relativePath,
    document.componentType,
    document.group,
  ]
    .join(' ')
    .toLowerCase();
  return haystack.includes(query);
}

export function CommandPaletteModal({
  actions,
  documents,
  open,
  onClose,
  onRunAction,
  onSelectFile,
}: CommandPaletteModalProps) {
  const [query, setQuery] = useState('');
  const inputRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (!open) {
      setQuery('');
      return;
    }

    const focusId = window.setTimeout(() => {
      inputRef.current?.focus();
      inputRef.current?.select();
    }, 10);

    return () => {
      window.clearTimeout(focusId);
    };
  }, [open]);

  // No early return, the backdrop handles visibility via [data-open] CSS rule

  const normalizedQuery = query.trim().toLowerCase();
  const visibleDocuments = documents.filter((document) => matchesDocument(document, normalizedQuery));
  const visibleActions = actions.filter((action) => matchesAction(action, normalizedQuery));

  function runFirstResult() {
    if (visibleDocuments.length > 0) {
      onSelectFile(visibleDocuments[0].id);
      onClose();
      return;
    }

    if (visibleActions.length > 0) {
      onRunAction(visibleActions[0].id);
      onClose();
    }
  }

  return (
    <div
      className="cmd-palette-backdrop"
      data-open={open}
      onClick={(event) => {
        if (event.target === event.currentTarget) {
          onClose();
        }
      }}
    >
      <div className="cmd-palette-modal" role="dialog" aria-modal="true" aria-label="Command palette">
        <input
          ref={inputRef}
          type="text"
          className="cmd-palette-input"
          value={query}
          placeholder="Search files, commands or panels..."
          onChange={(event) => setQuery(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === 'Escape') {
              event.preventDefault();
              onClose();
              return;
            }

            if (event.key === 'Enter') {
              event.preventDefault();
              runFirstResult();
            }
          }}
        />

        <div className="cmd-results" style={{ padding: '12px 0', maxHeight: '40vh', overflowY: 'auto' }}>
          <div>
            <div className="val-group-header" style={{ margin: '4px 16px' }}>Files</div>
            {visibleDocuments.length > 0 ? (
              visibleDocuments.map((document) => (
                <button
                  key={document.id}
                  type="button"
                  className="val-item"
                  style={{ borderRadius: 0, display: 'flex', alignItems: 'center', gap: 12, border: 'none', width: '100%' }}
                  onClick={() => {
                    onSelectFile(document.id);
                    onClose();
                  }}
                >
                  <span style={{ opacity: 0.5, flexShrink: 0 }}>📄</span>
                  <span style={{ flex: 1, textAlign: 'left', minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{document.fileName}</span>
                  <span className="val-loc" style={{ flexShrink: 0 }}>{document.relativePath}</span>
                </button>
              ))
            ) : (
              <p style={{ margin: '4px 16px', color: 'var(--text-dim)', fontSize: 11 }}>No matching files.</p>
            )}
          </div>

          <div style={{ marginTop: 12 }}>
            <div className="val-group-header" style={{ margin: '4px 16px' }}>Actions</div>
            {visibleActions.length > 0 ? (
              visibleActions.map((action) => (
                <button
                  key={action.id}
                  type="button"
                  className="val-item"
                  style={{ borderRadius: 0, display: 'flex', alignItems: 'center', gap: 12, border: 'none', width: '100%' }}
                  onClick={() => {
                    onRunAction(action.id);
                    onClose();
                  }}
                >
                  <span style={{ opacity: 0.5, flexShrink: 0 }}>⚡</span>
                  <span style={{ flex: 1, textAlign: 'left', minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{action.label}</span>
                  <span className="val-loc" style={{ flexShrink: 0 }}>{action.category}</span>
                </button>
              ))
            ) : (
              <p style={{ margin: '4px 16px', color: 'var(--text-dim)', fontSize: 11 }}>No matching actions.</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
