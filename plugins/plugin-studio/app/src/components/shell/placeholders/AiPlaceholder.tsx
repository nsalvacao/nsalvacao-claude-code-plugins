const aiActions = ['Suggest', 'Improve', 'Explain', 'Generate'];

export function AiPlaceholder() {
  return (
    <div className="flex h-full flex-col gap-4 p-4">
      <div className="studio-preview-card">
        <p className="text-xs font-semibold uppercase tracking-[0.28em] text-[var(--studio-accent-cyan)]">
          Provider
        </p>
        <p className="mt-2 text-sm font-medium text-slate-100">Claude CLI</p>
        <p className="mt-2 text-sm text-slate-400">
          Context-aware AI actions arrive in issue #13.
        </p>
      </div>

      <div className="grid grid-cols-2 gap-2">
        {aiActions.map((action) => (
          <button key={action} type="button" className="studio-ghost-button" disabled>
            {action}
          </button>
        ))}
      </div>

      <div className="studio-message-shell">
        <p className="text-xs font-semibold uppercase tracking-[0.28em] text-slate-500">
          Context snapshot
        </p>
        <p className="mt-3 text-sm leading-6 text-slate-300">
          Future messages will know the active plugin, file type, validation issues and editor selection.
        </p>
      </div>

      <div className="studio-input-shell mt-auto">
        <span className="text-sm text-slate-400">Ask AI about the active component...</span>
        <button type="button" className="studio-shell-button studio-shell-button--primary" disabled>
          SEND
        </button>
      </div>
    </div>
  );
}
