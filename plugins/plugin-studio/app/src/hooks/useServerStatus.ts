import { useEffect, useState } from 'react';
import type { ServerStatus } from '../types/studio.ts';

const CHECK_INTERVAL_MS = 15_000;
const REQUEST_TIMEOUT_MS = 2_500;

const INITIAL_STATUS: ServerStatus = {
  connection: 'checking',
  version: null,
  note: null,
  checkedAt: null,
};

function isStatusPayload(value: unknown): value is {
  status?: string;
  version?: string;
  note?: string;
} {
  return typeof value === 'object' && value !== null;
}

export function useServerStatus() {
  const [serverStatus, setServerStatus] = useState<ServerStatus>(INITIAL_STATUS);

  useEffect(() => {
    let active = true;
    let latestRequestId = 0;

    async function checkServer(showChecking: boolean) {
      const requestId = latestRequestId + 1;
      latestRequestId = requestId;

      if (showChecking) {
        setServerStatus((previous) => ({
          ...previous,
          connection: 'checking',
        }));
      }

      const controller = new AbortController();
      const timeoutId = window.setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

      try {
        const response = await fetch('/api/', {
          headers: { Accept: 'application/json' },
          signal: controller.signal,
        });

        if (!response.ok) {
          throw new Error(`Unexpected response: ${response.status}`);
        }

        const payload = await response.json();

        if (!active || requestId !== latestRequestId) return;
        if (!isStatusPayload(payload)) {
          throw new Error('Invalid API response format');
        }

        setServerStatus({
          connection: payload.status === 'ok' ? 'connected' : 'disconnected',
          version: typeof payload.version === 'string' ? payload.version : null,
          note: typeof payload.note === 'string' ? payload.note : null,
          checkedAt: Date.now(),
        });
      } catch {
        if (!active || requestId !== latestRequestId) return;

        setServerStatus((previous) => ({
          connection: 'disconnected',
          version: previous.version,
          note: previous.note,
          checkedAt: Date.now(),
        }));
      } finally {
        window.clearTimeout(timeoutId);
      }
    }

    void checkServer(true);

    const intervalId = window.setInterval(() => {
      void checkServer(false);
    }, CHECK_INTERVAL_MS);

    function handleFocus() {
      void checkServer(false);
    }

    window.addEventListener('focus', handleFocus);

    return () => {
      active = false;
      window.clearInterval(intervalId);
      window.removeEventListener('focus', handleFocus);
    };
  }, []);

  return serverStatus;
}
