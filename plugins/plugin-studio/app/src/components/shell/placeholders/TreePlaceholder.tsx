import type { ActivePluginInfo } from '../../../types/studio.ts';

const groups = [
  { name: 'manifest', count: '01', tone: 'amber' },
  { name: 'commands', count: '02', tone: 'cyan' },
  { name: 'skills', count: '01', tone: 'olive' },
  { name: 'agents', count: '01', tone: 'amber' },
  { name: 'hooks', count: '02', tone: 'cyan' },
  { name: 'MCP', count: '00', tone: 'olive' },
  { name: 'config', count: '01', tone: 'amber' },
];

interface TreePlaceholderProps {
  activePlugin: ActivePluginInfo;
}

export function TreePlaceholder({ activePlugin }: TreePlaceholderProps) {
  return (
    <div className="flex h-full flex-col gap-4 p-4">
      <div className="studio-search-box">
        <span className="studio-search-box__hint">Search</span>
        <div className="mt-2 flex items-center justify-between gap-3">
          <span className="text-sm text-slate-300">Find components, files, paths</span>
          <span className="studio-hotkey">CMD+K</span>
        </div>
      </div>

      <div className="grid gap-2">
        {groups.map((group) => (
          <div key={group.name} className="studio-tree-row" data-tone={group.tone}>
            <div className="flex items-center gap-3">
              <span className="studio-tree-row__icon" aria-hidden="true" />
              <span className="font-medium text-slate-100">{group.name}</span>
            </div>
            <span className="text-xs uppercase tracking-[0.28em] text-slate-500">
              {group.count}
            </span>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-2">
        <button type="button" className="studio-ghost-button" disabled>
          + New
        </button>
        <button type="button" className="studio-ghost-button" disabled>
          Import
        </button>
      </div>

      <div className="studio-callout mt-auto">
        <p className="text-xs font-semibold uppercase tracking-[0.28em] text-[var(--studio-accent-cyan)]">
          Next up
        </p>
        <p className="mt-2 text-sm text-slate-300">
          {activePlugin.rootPath
            ? `Tree data for ${activePlugin.displayName} lands in issue #6.`
            : 'Open a plugin path to replace this anatomy scaffold in issue #6.'}
        </p>
      </div>
    </div>
  );
}
