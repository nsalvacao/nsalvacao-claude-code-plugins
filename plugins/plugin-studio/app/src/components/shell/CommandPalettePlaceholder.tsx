interface CommandPalettePlaceholderProps {
  onOpen: () => void;
}

export function CommandPalettePlaceholder({ onOpen }: CommandPalettePlaceholderProps) {
  return (
    <button
      type="button"
      className="search-trigger"
      aria-label="Open command palette"
      onClick={onOpen}
    >
      <span style={{ opacity: 0.7 }}>Search files, commands, actions…</span>
      <span className="kbd">Ctrl+K</span>
    </button>
  );
}
