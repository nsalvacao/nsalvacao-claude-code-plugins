interface ContextualAiLensProps {
  onClick: () => void;
}

export function ContextualAiLens({ onClick }: ContextualAiLensProps) {
  return (
    <button
      type="button"
      className="ai-lens"
      onClick={onClick}
      aria-label="Ask Nexo about the highlighted context"
    >
      ✦ Ask Nexo
    </button>
  );
}
