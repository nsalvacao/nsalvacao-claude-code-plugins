import type { ActivePluginInfo } from '../../types/studio.ts';

interface StudioHeaderProps {
  activePlugin: ActivePluginInfo;
  rightOpen: boolean;
  onToggleAi: () => void;
}

export function StudioHeader({ activePlugin, rightOpen, onToggleAi }: StudioHeaderProps) {
  return (
    <header className="relative z-10 border-b border-white/10 bg-slate-950/70 px-4 py-4 backdrop-blur-xl">
      <div className="flex items-center justify-between gap-4">
        <div className="min-w-0">
          <p className="text-[11px] font-semibold uppercase tracking-[0.36em] text-[var(--studio-accent-cyan)]">
            Local IDE for Claude Code plugins
          </p>
          <div className="mt-2 flex min-w-0 items-center gap-3">
            <span className="studio-mark">PS</span>
            <div className="min-w-0">
              <h1 className="truncate text-2xl font-semibold tracking-tight text-white">
                Plugin Studio
              </h1>
              <p className="truncate text-sm text-slate-400">
                Experimental shell for the v0.1 dashboard
              </p>
            </div>
          </div>
        </div>

        <div className="flex min-w-0 items-center gap-3">
          <div className="studio-plugin-chip min-w-0">
            <span className="studio-plugin-chip__label">Active plugin</span>
            <span className="truncate text-sm font-semibold text-slate-100">
              {activePlugin.displayName}
            </span>
            <span className="truncate text-xs text-slate-400">
              {activePlugin.rootPath ?? 'Waiting for /plugin-studio:open [path]'}
            </span>
          </div>

          <button
            type="button"
            className="studio-shell-button"
            title="Settings panel lands in a later issue"
            aria-label="Settings placeholder"
          >
            SETTINGS
          </button>

          <button
            type="button"
            className="studio-shell-button studio-shell-button--primary"
            aria-pressed={rightOpen}
            aria-label={rightOpen ? 'Collapse AI panel' : 'Expand AI panel'}
            onClick={onToggleAi}
          >
            {rightOpen ? 'AI OPEN' : 'AI CLOSED'}
          </button>
        </div>
      </div>
    </header>
  );
}
