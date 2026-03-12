import type { ReactNode } from 'react';

type PanelTone = 'amber' | 'cyan' | 'olive' | 'slate';

interface PanelFrameProps {
  title: string;
  subtitle?: string;
  badge?: string;
  tone?: PanelTone;
  actions?: ReactNode;
  children: ReactNode;
  className?: string;
  bodyClassName?: string;
}

function joinClasses(...classes: Array<string | undefined>) {
  return classes.filter(Boolean).join(' ');
}

export function PanelFrame({
  title,
  subtitle,
  badge,
  tone = 'slate',
  actions,
  children,
  className,
  bodyClassName,
}: PanelFrameProps) {
  return (
    <section
      data-tone={tone}
      className={joinClasses(
        'studio-panel flex h-full min-h-0 flex-col overflow-hidden',
        className,
      )}
    >
      <header className="studio-panel-header flex items-start justify-between gap-3">
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <span className="studio-panel-dot" aria-hidden="true" />
            <h2 className="truncate text-sm font-semibold uppercase tracking-[0.22em] text-slate-100">
              {title}
            </h2>
            {badge ? <span className="studio-badge">{badge}</span> : null}
          </div>
          {subtitle ? (
            <p className="mt-2 text-sm text-slate-400">
              {subtitle}
            </p>
          ) : null}
        </div>
        {actions ? <div className="shrink-0">{actions}</div> : null}
      </header>
      <div className={joinClasses('min-h-0 flex-1', bodyClassName)}>
        {children}
      </div>
    </section>
  );
}
