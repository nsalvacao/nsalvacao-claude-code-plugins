import type { ActiveDocumentInfo, AiChatMessage, DemoDocument } from '../../types/studio.ts';
import { AiPlaceholder } from './placeholders/AiPlaceholder.tsx';

interface AiRailProps {
  activeDocument: ActiveDocumentInfo;
  chatMessages: AiChatMessage[];
  document: DemoDocument | null;
  open: boolean;
  onSend: (prompt: string) => void;
  onToggle: () => void;
}

export function AiRail({
  activeDocument,
  chatMessages,
  document,
  open,
  onSend,
  onToggle,
}: AiRailProps) {
  return (
    <aside className="ai-drawer" data-mode={open ? 'open' : 'rail'}>
      <div className="ai-rail-view">
        <button
          type="button"
          className="btn-ai-vertical"
          aria-label="Expand AI drawer"
          onClick={onToggle}
        >
          NEXO
        </button>
      </div>

      <div className="ai-open-view">
        <header className="ai-header">
          <div className="ai-title">
            <div className="ai-status-dot" /> Nexo drawer
          </div>
          <button
            type="button"
            className="btn-ghost"
            onClick={onToggle}
            aria-label="Collapse AI drawer"
            title="Collapse to rail"
          >
            CLOSE
          </button>
        </header>

        <AiPlaceholder
          activeDocument={activeDocument}
          chatMessages={chatMessages}
          document={document}
          onSend={onSend}
        />
      </div>
    </aside>
  );
}
