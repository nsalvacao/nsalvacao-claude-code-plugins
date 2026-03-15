import type {
  ActivePluginInfo,
  DemoDocument,
  DemoDocumentGroup,
  DemoTreeGroup,
  TreePanelMode,
} from '../../../types/studio.ts';

interface TreePlaceholderProps {
  activeFileId: string | null;
  activeGroupId: DemoDocumentGroup | null;
  activePlugin: ActivePluginInfo;
  countsByGroup: Record<DemoDocumentGroup, number>;
  groups: DemoTreeGroup[];
  mode: TreePanelMode;
  treeFilter: string;
  visibleDocuments: DemoDocument[];
  onSelectFile: (fileId: string) => void;
  onSelectGroup: (groupId: DemoDocumentGroup) => void;
  onTreeFilterChange: (value: string) => void;
}

function renderCompactView(
  activeGroupId: DemoDocumentGroup | null,
  activePlugin: ActivePluginInfo,
  countsByGroup: Record<DemoDocumentGroup, number>,
  groups: DemoTreeGroup[],
  onSelectGroup: (groupId: DemoDocumentGroup) => void,
) {
  return (
    <>
      <div className="compact-items">
        {groups.map((group) => (
          <button
            key={group.id}
            type="button"
            className={`compact-item tone-${group.tone}`}
            data-active={activeGroupId === group.id}
            title={`${group.label} (${String(countsByGroup[group.id]).padStart(2, '0')})`}
            onClick={() => onSelectGroup(group.id)}
          >
            <span className="compact-sigil">{group.sigil}</span>
            <span className="compact-count">
              {String(countsByGroup[group.id]).padStart(2, '0')}
            </span>
          </button>
        ))}
      </div>
      <div style={{ marginTop: 'auto', padding: '16px', textAlign: 'center', color: 'var(--text-dim)', fontSize: 10, fontWeight: 700 }}>
        {activePlugin.rootPath ? activePlugin.displayName.slice(0, 2).toUpperCase() : 'PS'}
      </div>
    </>
  );
}

export function TreePlaceholder({
  activeFileId,
  activeGroupId,
  activePlugin,
  countsByGroup,
  groups,
  mode,
  treeFilter,
  visibleDocuments,
  onSelectFile,
  onSelectGroup,
  onTreeFilterChange,
}: TreePlaceholderProps) {
  if (mode === 'compact') {
    return renderCompactView(activeGroupId, activePlugin, countsByGroup, groups, onSelectGroup);
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div className="tree-search-container">
        <div className="tree-search">
          <input
            type="text"
            value={treeFilter}
            placeholder="Search files, groups or types..."
            onChange={(event) => onTreeFilterChange(event.target.value)}
          />
          <span className="kbd">Live</span>
        </div>
      </div>

      <div className="tree-content">
        <div className="tree-item folder">
          <span className="tree-icon">▼</span>
          <span className="tree-label">
            {activePlugin.rootPath ? activePlugin.displayName : 'plugin-root'}
          </span>
        </div>

        {groups.map((group) => {
          const groupDocuments = visibleDocuments.filter((document) => document.group === group.id);
          if (groupDocuments.length === 0) return null;

          return (
            <div key={group.id}>
              <button
                type="button"
                className="tree-item folder"
                data-tone={group.tone}
                onClick={() => onSelectGroup(group.id)}
              >
                <span className="tree-icon">▨</span>
                <span className="tree-label">{group.label}</span>
                <span style={{ fontSize: 10, opacity: 0.5, marginLeft: 'auto' }}>
                  {String(countsByGroup[group.id]).padStart(2, '0')}
                </span>
              </button>

              <div>
                {groupDocuments.map((document) => (
                  <button
                    key={document.id}
                    type="button"
                    className={`tree-item file-node ${document.id === activeFileId ? 'active' : ''}`}
                    onClick={() => onSelectFile(document.id)}
                  >
                    <span className="tree-indent" />
                    <span className="tree-icon">📄</span>
                    <span className="tree-label" style={{ opacity: document.id === activeFileId ? 1 : 0.8 }}>
                      {document.fileName}
                    </span>
                  </button>
                ))}
              </div>
            </div>
          );
        })}
      </div>

      <div style={{ padding: '16px', color: 'var(--text-dim)', fontSize: 11, borderTop: '1px solid var(--border-subtle)' }}>
        {treeFilter.trim()
          ? `${visibleDocuments.length} matching components in the current scaffold.`
          : activePlugin.rootPath
            ? `Issue #6 will swap this scaffold for the real anatomy of ${activePlugin.displayName}.`
            : 'Open a plugin path to replace this scaffold with the real filesystem tree.'}
      </div>
    </div>
  );
}
