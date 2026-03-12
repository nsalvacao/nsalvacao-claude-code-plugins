const previewCards = [
  {
    title: 'Markdown preview',
    body: 'Rendered docs, command bodies and agent prompts get a formatted reading mode in issue #8.',
  },
  {
    title: 'JSON pretty view',
    body: 'Manifest and hook config files get structure-first formatting for fast scanning.',
  },
  {
    title: 'YAML awareness',
    body: 'Frontmatter becomes inspectable side-by-side with the editor for fast validation loops.',
  },
];

export function PreviewPlaceholder() {
  return (
    <div className="flex h-full flex-col gap-3 p-4">
      {previewCards.map((card) => (
        <article key={card.title} className="studio-preview-card">
          <p className="text-xs font-semibold uppercase tracking-[0.28em] text-[var(--studio-accent-olive)]">
            {card.title}
          </p>
          <p className="mt-3 text-sm leading-6 text-slate-300">
            {card.body}
          </p>
        </article>
      ))}

      <div className="studio-callout mt-auto">
        <p className="text-xs font-semibold uppercase tracking-[0.28em] text-[var(--studio-accent-amber)]">
          Preview mode
        </p>
        <p className="mt-2 text-sm text-slate-300">
          Side-by-side reading ships here visually now and becomes functional in issue #8.
        </p>
      </div>
    </div>
  );
}
