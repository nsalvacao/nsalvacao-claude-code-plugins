import type { DemoDocument, EditorLine } from '../../../types/studio.ts';
import { ContextualAiLens } from '../ContextualAiLens.tsx';

interface EditorPlaceholderProps {
  document: DemoDocument | null;
  onAskAi: () => void;
}

function renderLineTone(tone: EditorLine['tone']) {
  if (tone === 'comment') return 'comment';
  if (tone === 'keyword') return 'keyword';
  if (tone === 'prop') return 'prop';
  if (tone === 'string') return 'string';
  return '';
}

export function EditorPlaceholder({ document, onAskAi }: EditorPlaceholderProps) {
  if (!document) {
    return (
      <div className="editor-surface" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: 0.5 }}>
        <p>No active editor.</p>
      </div>
    );
  }

  return (
    <div className="editor-surface">
      {document.editorLines.map((line, index) => (
        <div
          key={`${document.id}-${index + 1}-${line.text}`}
          className={`code-line ${line.lens ? 'has-lens' : ''}`}
        >
          <span className="ln">{index + 1}</span>
          <span className="code">
            <span className={renderLineTone(line.tone)}>{line.text || ' '}</span>
            {line.lens ? <ContextualAiLens onClick={onAskAi} /> : null}
          </span>
        </div>
      ))}
    </div>
  );
}
