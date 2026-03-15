import type {
  ActivePluginInfo,
  DemoDocument,
  DemoDocumentGroup,
  DemoTreeGroup,
  TreePanelMode,
} from '../../types/studio.ts';
import { COMPACT_LEFT_WIDTH } from '../../hooks/useStudioLayout.ts';
import { TreePlaceholder } from './placeholders/TreePlaceholder.tsx';

interface TreeRailProps {
  activeFileId: string | null;
  activeGroupId: DemoDocumentGroup | null;
  activePlugin: ActivePluginInfo;
  countsByGroup: Record<DemoDocumentGroup, number>;
  groups: DemoTreeGroup[];
  mode: TreePanelMode;
  treeFilter: string;
  visibleDocuments: DemoDocument[];
  expandedWidth: number;
  onSelectFile: (fileId: string) => void;
  onSelectGroup: (groupId: DemoDocumentGroup) => void;
  onSetMode: (mode: TreePanelMode) => void;
  onTreeFilterChange: (value: string) => void;
}

export function TreeRail({
  activeFileId,
  activeGroupId,
  activePlugin,
  countsByGroup,
  groups,
  mode,
  treeFilter,
  visibleDocuments,
  expandedWidth,
  onSelectFile,
  onSelectGroup,
  onSetMode,
  onTreeFilterChange,
}: TreeRailProps) {
  const width = mode === 'expanded' ? expandedWidth : COMPACT_LEFT_WIDTH;
  const isCompact = mode === 'compact';

  return (
    <aside
      style={{ width }}
      className="sidebar-tree"
      data-mode={mode}
    >
      <div className="sidebar-header">
        {isCompact ? (
          <button
            type="button"
            className="btn-ghost"
            onClick={() => onSetMode('expanded')}
            title="Expand tree"
          >
            ▸
          </button>
        ) : (
          <>
            <span className="sidebar-title">Explorer</span>
            <button
              type="button"
              className="btn-ghost"
              style={{ padding: '2px 6px' }}
              onClick={() => onSetMode('compact')}
              title="Collapse to rail"
            >
              ◂
            </button>
          </>
        )}
      </div>

      <div className="sidebar-body">
        <TreePlaceholder
          activeFileId={activeFileId}
          activeGroupId={activeGroupId}
          activePlugin={activePlugin}
          countsByGroup={countsByGroup}
          groups={groups}
          mode={mode}
          treeFilter={treeFilter}
          visibleDocuments={visibleDocuments}
          onSelectFile={onSelectFile}
          onSelectGroup={onSelectGroup}
          onTreeFilterChange={onTreeFilterChange}
        />
      </div>
    </aside>
  );
}
