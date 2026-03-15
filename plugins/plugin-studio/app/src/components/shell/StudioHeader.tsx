import type {
  ActiveDocumentInfo,
  ActivePluginInfo,
  BreadcrumbItem,
  ServerStatus,
  TreePanelMode,
} from '../../types/studio.ts';
import { CommandPalettePlaceholder } from './CommandPalettePlaceholder.tsx';

interface StudioHeaderProps {
  activePlugin: ActivePluginInfo;
  activeDocument: ActiveDocumentInfo;
  breadcrumbs: BreadcrumbItem[];
  serverStatus: ServerStatus;
  leftMode: TreePanelMode;
  rightOpen: boolean;
  onCycleTree: () => void;
  onOpenCommandPalette: () => void;
  onToggleAi: () => void;
}

function getConnectionLabel(connection: ServerStatus['connection']) {
  if (connection === 'connected') return 'Runtime online';
  if (connection === 'disconnected') return 'Runtime offline';
  return 'Checking runtime';
}

function getTreeLabel(leftMode: TreePanelMode) {
  if (leftMode === 'expanded') return 'TREE FULL';
  if (leftMode === 'compact') return 'TREE MINI';
  return 'TREE OFF';
}

export function StudioHeader({
  activePlugin,
  activeDocument,
  breadcrumbs,
  serverStatus,
  leftMode,
  rightOpen,
  onCycleTree,
  onOpenCommandPalette,
  onToggleAi,
}: StudioHeaderProps) {
  const headerBreadcrumbs = breadcrumbs.length > 0
    ? breadcrumbs
    : [
      { label: activePlugin.displayName },
      { label: activeDocument.name || 'Workbench', current: true },
    ];

  return (
    <header className="studio-header">
      <div className="brand-container">
        <div className="brand">
          <div className="brand-mark">PS</div>
          <div className="brand-copy">
            <span className="brand-tag">Local plugin workbench</span>
            <span className="brand-text">Plugin Studio</span>
          </div>
        </div>
        <span className="runtime-pill" data-connection={serverStatus.connection}>
          {getConnectionLabel(serverStatus.connection)}
        </span>
      </div>

      <div className="header-center">
        <div className="breadcrumbs">
          {headerBreadcrumbs.map((breadcrumb, index) => (
            <div key={`${breadcrumb.label}-${index}`} className="breadcrumbs-item">
              {index > 0 ? <span className="sep">/</span> : null}
              <span className={index === 0 ? 'plugin-name' : breadcrumb.current ? 'active' : ''}>
                {breadcrumb.label}
              </span>
            </div>
          ))}
        </div>

        <CommandPalettePlaceholder onOpen={onOpenCommandPalette} />
      </div>

      <div className="header-actions">
        <button
          type="button"
          className="btn-ghost"
          aria-label="Cycle tree panel mode"
          onClick={onCycleTree}
        >
          {getTreeLabel(leftMode)}
        </button>

        <button
          type="button"
          className="btn-ghost"
          title="Settings panel lands in a later issue"
          aria-label="Settings placeholder"
        >
          SETTINGS
        </button>

        <button
          type="button"
          className="btn-accent"
          aria-pressed={rightOpen}
          aria-label={rightOpen ? 'Collapse AI panel' : 'Expand AI panel'}
          onClick={onToggleAi}
        >
          {rightOpen ? 'AI OPEN' : 'AI RAIL'}
        </button>
      </div>
    </header>
  );
}
