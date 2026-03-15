import type { ToastMessage } from '../../types/studio.ts';

interface ToastHostProps {
  toasts: ToastMessage[];
}

export function ToastHost({ toasts }: ToastHostProps) {
  if (toasts.length === 0) return null;

  return (
    <div className="toast-container" aria-live="polite" aria-atomic="false">
      {toasts.map((toast) => (
        <div key={toast.id} className="toast-msg" data-tone={toast.tone}>
          <span
            className={toast.tone === 'success' ? 'toast-success-icon' : 'toast-icon'}
            aria-hidden="true"
          >
            {toast.tone === 'success' ? '✔' : toast.tone === 'warning' ? '!' : 'i'}
          </span>
          <span>{toast.message}</span>
        </div>
      ))}
    </div>
  );
}
