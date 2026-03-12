import type { ServerStatus } from '../../types/studio.ts';

interface StatusBarProps {
  serverStatus: ServerStatus;
}

function getConnectionLabel(connection: ServerStatus['connection']) {
  if (connection === 'connected') return 'Connected';
  if (connection === 'disconnected') return 'Disconnected';
  return 'Checking';
}

function getConnectionNote(serverStatus: ServerStatus) {
  if (serverStatus.connection === 'connected') {
    return serverStatus.note ?? 'Local runtime reachable';
  }

  if (serverStatus.connection === 'disconnected') {
    return 'Server unavailable';
  }

  return 'Polling local server';
}

export function StatusBar({ serverStatus }: StatusBarProps) {
  const versionLabel = serverStatus.version ? `v${serverStatus.version}` : 'v?';

  return (
    <footer className="border-t border-white/10 bg-slate-950/85 px-4 py-2 backdrop-blur-xl">
      <div className="grid grid-cols-4 gap-2 text-sm">
        <div className="studio-status-item">
          <span className={`studio-status-dot studio-status-dot--${serverStatus.connection}`} aria-hidden="true" />
          <div>
            <p className="studio-status-item__label">Connection</p>
            <p className="studio-status-item__value">{getConnectionLabel(serverStatus.connection)}</p>
            <p className="studio-status-item__note">{getConnectionNote(serverStatus)}</p>
          </div>
        </div>

        <div className="studio-status-item">
          <div>
            <p className="studio-status-item__label">AI provider</p>
            <p className="studio-status-item__value">Claude CLI</p>
            <p className="studio-status-item__note">Roadmap path for #13</p>
          </div>
        </div>

        <div className="studio-status-item">
          <div>
            <p className="studio-status-item__label">Auto-save</p>
            <p className="studio-status-item__value">ON</p>
            <p className="studio-status-item__note">Shell signal only in #5</p>
          </div>
        </div>

        <div className="studio-status-item justify-self-end">
          <div className="text-right">
            <p className="studio-status-item__label">Version</p>
            <p className="studio-status-item__value">{versionLabel}</p>
            <p className="studio-status-item__note">Core dashboard MVP</p>
          </div>
        </div>
      </div>
    </footer>
  );
}
