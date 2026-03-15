import { useState } from 'react';
import type { ActiveDocumentInfo, AiChatMessage, DemoDocument } from '../../../types/studio.ts';

interface AiPlaceholderProps {
  activeDocument: ActiveDocumentInfo;
  chatMessages: AiChatMessage[];
  document: DemoDocument | null;
  onSend: (prompt: string) => void;
}

export function AiPlaceholder({
  activeDocument,
  chatMessages,
  document,
  onSend,
}: AiPlaceholderProps) {
  const [prompt, setPrompt] = useState('');

  function handleSend() {
    const nextPrompt = prompt.trim();
    if (!nextPrompt) return;
    onSend(nextPrompt);
    setPrompt('');
  }

  return (
    <>
      <div className="ai-content">
        <p style={{ fontSize: 11, color: 'var(--text-dim)', margin: 0 }}>
          {document?.aiContextNote ?? 'Open a plugin and the assistant will inherit plugin-aware context from the shell.'}
        </p>

        {chatMessages.map((message) => (
          <div
            key={message.id}
            className={`chat-msg ${message.role === 'assistant' ? 'msg-ai' : 'msg-user'}`}
          >
            {message.text}
          </div>
        ))}
      </div>

      <div className="ai-input-area">
        <div className="input-box">
          <textarea
            value={prompt}
            placeholder="Review structure, explain context or propose the next safe change."
            onChange={(event) => setPrompt(event.target.value)}
            onKeyDown={(event) => {
              if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
                event.preventDefault();
                handleSend();
              }
            }}
          />
          <div className="input-footer">
            <span className="input-hint">
              Context: {activeDocument.name || 'None'}
            </span>
            <button
              type="button"
              className="btn-accent"
              onClick={handleSend}
            >
              SEND
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
