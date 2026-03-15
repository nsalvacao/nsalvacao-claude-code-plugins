import type { DemoDocument, PreviewBlock } from '../../../types/studio.ts';

interface PreviewPlaceholderProps {
  document: DemoDocument | null;
}

function renderBlock(block: PreviewBlock, index: number) {
  if (block.kind === 'heading1') {
    return <h1 key={`heading1-${index}`}>{block.text}</h1>;
  }

  if (block.kind === 'heading2') {
    return <h2 key={`heading2-${index}`}>{block.text}</h2>;
  }

  if (block.kind === 'code') {
    return (
      <pre key={`code-${index}`}>
        <code>{block.text}</code>
      </pre>
    );
  }

  if (block.kind === 'list') {
    return (
      <ul key={`list-${index}`}>
        {(block.items ?? []).map((item) => (
          <li key={item}>{item}</li>
        ))}
      </ul>
    );
  }

  return (
    <p key={`paragraph-${index}`} data-tone={block.tone ?? 'default'}>
      {block.text}
    </p>
  );
}

export function PreviewPlaceholder({ document }: PreviewPlaceholderProps) {
  if (!document) {
    return (
      <div className="preview-surface">
        <article className="reading-column">
          <p>Select a component to light up the reading surface.</p>
        </article>
      </div>
    );
  }

  return (
    <div className="preview-surface">
      <article className="reading-column">
        {document.preview.map((block, index) => renderBlock(block, index))}
      </article>
    </div>
  );
}
