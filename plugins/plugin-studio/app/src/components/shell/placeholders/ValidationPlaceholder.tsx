import type { ActivePluginInfo } from '../../../types/studio.ts';

const previewIssues = [
  '[warning] commands/open.md:2 — argument-hint still pending',
  '[info] README.md:12 — preview wiring lands in #8',
  '[info] hooks/hooks.json:1 — validation backend is ready from #4',
];

interface ValidationPlaceholderProps {
  activePlugin: ActivePluginInfo;
}

export function ValidationPlaceholder({ activePlugin }: ValidationPlaceholderProps) {
  return (
    <div className="flex h-full flex-col gap-4 p-4">
      <div className="grid grid-cols-[1.2fr_1fr_auto] items-center gap-4">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.28em] text-[var(--studio-accent-cyan)]">
            Validation backend
          </p>
          <p className="mt-2 text-sm text-slate-300">
            {activePlugin.rootPath
              ? `Ready to validate ${activePlugin.displayName}; UI wiring lands in issue #9.`
              : 'Backend routes are live from issue #4; load a plugin path to light this panel up later.'}
          </p>
        </div>

        <div className="studio-health-shell">
          <span className="text-xs font-semibold uppercase tracking-[0.28em] text-slate-500">
            Health score
          </span>
          <strong className="mt-2 text-3xl text-slate-100">--</strong>
          <div className="studio-health-bar mt-3">
            <div className="studio-health-bar__fill" />
          </div>
        </div>

        <button type="button" className="studio-shell-button studio-shell-button--primary" disabled>
          RUN ALL
        </button>
      </div>

      <div className="grid gap-2">
        {previewIssues.map((issue) => (
          <div key={issue} className="studio-validation-row">
            {issue}
          </div>
        ))}
      </div>
    </div>
  );
}
