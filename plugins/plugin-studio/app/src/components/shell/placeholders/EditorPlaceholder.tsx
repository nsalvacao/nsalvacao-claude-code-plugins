const editorLines = [
  '---',
  'description: Open the dashboard shell',
  'arguments: [path]',
  '---',
  '# Plugin Studio',
  '',
  'This shell becomes the Monaco editor in issue #7.',
  '',
  'Focus for #5:',
  '- split layout',
  '- resize behavior',
  '- shell chrome',
];

export function EditorPlaceholder() {
  return (
    <div className="studio-grid-surface flex h-full flex-col p-4">
      <div className="flex items-center justify-between gap-3">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.28em] text-slate-400">
            Active file
          </p>
          <p className="mt-2 text-sm font-medium text-slate-100">
            commands/open.md
          </p>
        </div>
        <div className="flex gap-2">
          <span className="studio-badge">Split</span>
          <span className="studio-badge">Monaco in #7</span>
        </div>
      </div>

      <div className="studio-code-surface mt-4 min-h-0 flex-1 overflow-auto">
        <div className="grid grid-cols-[40px_1fr] gap-x-4 gap-y-2 p-4 font-mono text-sm">
          {editorLines.map((line, index) => (
            <div key={`${index + 1}-${line}`} className="contents">
              <span className="text-right text-slate-500">{index + 1}</span>
              <span className="text-slate-200">{line || ' '}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
