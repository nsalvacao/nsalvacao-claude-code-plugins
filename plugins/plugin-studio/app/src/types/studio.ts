export type ServerConnectionState = 'checking' | 'connected' | 'disconnected';

export interface ServerStatus {
  connection: ServerConnectionState;
  version: string | null;
  note: string | null;
  checkedAt: number | null;
}

export interface StudioLayoutState {
  leftWidth: number;
  centerSplit: number;
  rightOpen: boolean;
  bottomOpen: boolean;
  bottomHeight: number;
}

export interface ActivePluginInfo {
  rootPath: string | null;
  displayName: string;
}
