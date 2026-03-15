import { useEffect, useState } from 'react';
import type { StudioLayoutState, TreePanelMode, WorkspaceViewMode } from '../types/studio.ts';

const STORAGE_KEY = 'plugin-studio.layout.v4';
export const COMPACT_LEFT_WIDTH = 72;
export const MIN_LEFT_WIDTH = 240;
export const MAX_LEFT_WIDTH = 360;
export const MIN_CENTER_SPLIT = 0.38;
export const MAX_CENTER_SPLIT = 0.68;
export const AI_RAIL_WIDTH = 56;
export const MIN_BOTTOM_HEIGHT = 108;
export const MAX_BOTTOM_HEIGHT = 208;

const DEFAULT_LAYOUT: StudioLayoutState = {
  leftMode: 'expanded',
  leftWidth: 280,
  centerSplit: 0.52,
  rightOpen: false,
  bottomOpen: false,
  bottomHeight: 144,
  workspaceMode: 'split',
};

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function isTreePanelMode(value: unknown): value is TreePanelMode {
  return value === 'expanded' || value === 'compact' || value === 'collapsed';
}

function isWorkspaceViewMode(value: unknown): value is WorkspaceViewMode {
  return value === 'edit' || value === 'preview' || value === 'split';
}

function normalizeLayout(payload: Partial<StudioLayoutState>): StudioLayoutState {
  return {
    leftMode: isTreePanelMode(payload.leftMode) ? payload.leftMode : DEFAULT_LAYOUT.leftMode,
    leftWidth: clamp(
      typeof payload.leftWidth === 'number' ? payload.leftWidth : DEFAULT_LAYOUT.leftWidth,
      MIN_LEFT_WIDTH,
      MAX_LEFT_WIDTH,
    ),
    centerSplit: clamp(
      typeof payload.centerSplit === 'number' ? payload.centerSplit : DEFAULT_LAYOUT.centerSplit,
      MIN_CENTER_SPLIT,
      MAX_CENTER_SPLIT,
    ),
    rightOpen: typeof payload.rightOpen === 'boolean' ? payload.rightOpen : DEFAULT_LAYOUT.rightOpen,
    bottomOpen: typeof payload.bottomOpen === 'boolean' ? payload.bottomOpen : DEFAULT_LAYOUT.bottomOpen,
    bottomHeight: clamp(
      typeof payload.bottomHeight === 'number' ? payload.bottomHeight : DEFAULT_LAYOUT.bottomHeight,
      MIN_BOTTOM_HEIGHT,
      MAX_BOTTOM_HEIGHT,
    ),
    workspaceMode: isWorkspaceViewMode(payload.workspaceMode)
      ? payload.workspaceMode
      : DEFAULT_LAYOUT.workspaceMode,
  };
}

function loadLayout() {
  if (typeof window === 'undefined') return DEFAULT_LAYOUT;

  try {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    if (!stored) return DEFAULT_LAYOUT;
    return normalizeLayout(JSON.parse(stored) as Partial<StudioLayoutState>);
  } catch {
    return DEFAULT_LAYOUT;
  }
}

export function useStudioLayout() {
  const [layout, setLayout] = useState<StudioLayoutState>(loadLayout);

  useEffect(() => {
    const persistId = window.setTimeout(() => {
      try {
        window.localStorage.setItem(STORAGE_KEY, JSON.stringify(layout));
      } catch {
        // Ignore persistence failures; the shell can still run with in-memory layout state.
      }
    }, 120);

    return () => {
      window.clearTimeout(persistId);
    };
  }, [layout]);

  function updateLeftWidth(nextWidth: number) {
    setLayout((previous) => ({
      ...previous,
      leftMode: 'expanded',
      leftWidth: clamp(nextWidth, MIN_LEFT_WIDTH, MAX_LEFT_WIDTH),
    }));
  }

  function updateCenterSplit(nextSplit: number) {
    setLayout((previous) => ({
      ...previous,
      centerSplit: clamp(nextSplit, MIN_CENTER_SPLIT, MAX_CENTER_SPLIT),
    }));
  }

  function setLeftMode(nextMode: TreePanelMode) {
    setLayout((previous) => ({
      ...previous,
      leftMode: nextMode,
    }));
  }

  function cycleLeftMode() {
    setLayout((previous) => {
      if (previous.leftMode === 'expanded') {
        return { ...previous, leftMode: 'compact' };
      }

      if (previous.leftMode === 'compact') {
        return { ...previous, leftMode: 'collapsed' };
      }

      return { ...previous, leftMode: 'expanded' };
    });
  }

  function toggleLeftPanel() {
    setLayout((previous) => ({
      ...previous,
      leftMode: previous.leftMode === 'collapsed' ? 'expanded' : 'collapsed',
    }));
  }

  function toggleRightPanel() {
    setLayout((previous) => ({
      ...previous,
      rightOpen: !previous.rightOpen,
    }));
  }

  function setRightPanelOpen(nextOpen: boolean) {
    setLayout((previous) => ({
      ...previous,
      rightOpen: nextOpen,
    }));
  }

  function toggleBottomPanel() {
    setLayout((previous) => ({
      ...previous,
      bottomOpen: !previous.bottomOpen,
    }));
  }

  function setWorkspaceMode(nextMode: WorkspaceViewMode) {
    setLayout((previous) => ({
      ...previous,
      workspaceMode: nextMode,
    }));
  }

  function updateBottomHeight(nextHeight: number) {
    setLayout((previous) => ({
      ...previous,
      bottomHeight: clamp(nextHeight, MIN_BOTTOM_HEIGHT, MAX_BOTTOM_HEIGHT),
    }));
  }

  return {
    layout,
    setLeftMode,
    cycleLeftMode,
    toggleLeftPanel,
    updateLeftWidth,
    updateCenterSplit,
    setRightPanelOpen,
    toggleRightPanel,
    toggleBottomPanel,
    setWorkspaceMode,
    updateBottomHeight,
  };
}
