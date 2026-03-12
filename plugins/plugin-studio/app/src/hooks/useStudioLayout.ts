import { useEffect, useState } from 'react';
import type { StudioLayoutState } from '../types/studio.ts';

const STORAGE_KEY = 'plugin-studio.layout.v1';
const MIN_LEFT_WIDTH = 220;
const MAX_LEFT_WIDTH = 420;
const MIN_CENTER_SPLIT = 0.35;
const MAX_CENTER_SPLIT = 0.65;

const DEFAULT_LAYOUT: StudioLayoutState = {
  leftWidth: 280,
  centerSplit: 0.5,
  rightOpen: true,
  bottomOpen: true,
  bottomHeight: 196,
};

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function normalizeLayout(payload: Partial<StudioLayoutState>): StudioLayoutState {
  return {
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
    bottomHeight: typeof payload.bottomHeight === 'number' ? payload.bottomHeight : DEFAULT_LAYOUT.bottomHeight,
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
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(layout));
    }, 120);

    return () => {
      window.clearTimeout(persistId);
    };
  }, [layout]);

  function updateLeftWidth(nextWidth: number) {
    setLayout((previous) => ({
      ...previous,
      leftWidth: clamp(nextWidth, MIN_LEFT_WIDTH, MAX_LEFT_WIDTH),
    }));
  }

  function updateCenterSplit(nextSplit: number) {
    setLayout((previous) => ({
      ...previous,
      centerSplit: clamp(nextSplit, MIN_CENTER_SPLIT, MAX_CENTER_SPLIT),
    }));
  }

  function toggleRightPanel() {
    setLayout((previous) => ({
      ...previous,
      rightOpen: !previous.rightOpen,
    }));
  }

  function toggleBottomPanel() {
    setLayout((previous) => ({
      ...previous,
      bottomOpen: !previous.bottomOpen,
    }));
  }

  return {
    layout,
    updateLeftWidth,
    updateCenterSplit,
    toggleRightPanel,
    toggleBottomPanel,
  };
}
