import type { PointerEvent as ReactPointerEvent } from 'react';
import type { KeyboardEvent as ReactKeyboardEvent } from 'react';

interface ResizeHandleProps {
  label: string;
  onPointerDown: (event: ReactPointerEvent<HTMLDivElement>) => void;
  valueNow?: number;
  valueMin?: number;
  valueMax?: number;
  onStep?: (direction: -1 | 1) => void;
}

export function ResizeHandle({
  label,
  onPointerDown,
  valueNow,
  valueMin,
  valueMax,
  onStep,
}: ResizeHandleProps) {
  function handleKeyDown(event: ReactKeyboardEvent<HTMLDivElement>) {
    if (!onStep) return;

    if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') {
      event.preventDefault();
      onStep(-1);
    }

    if (event.key === 'ArrowRight' || event.key === 'ArrowDown') {
      event.preventDefault();
      onStep(1);
    }
  }

  return (
    <div
      role="separator"
      aria-orientation="vertical"
      aria-label={label}
      aria-valuenow={valueNow}
      aria-valuemin={valueMin}
      aria-valuemax={valueMax}
      tabIndex={0}
      className="studio-resize-handle shrink-0"
      onPointerDown={onPointerDown}
      onKeyDown={handleKeyDown}
    >
      <div className="studio-resize-handle__line" />
    </div>
  );
}
