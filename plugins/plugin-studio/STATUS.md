# Plugin Studio Status

Canonical internal implementation-status note for the current checked-in state of `plugin-studio`.
Use this file as the source of truth for what is actually shipped in this branch. The public
[`README.md`](README.md) is ahead of reality in a few places and is owned by issue `#20`.

## Evidence Basis

- Based on the checked-in code under `plugins/plugin-studio/`.
- Backend reality verified with `node --test api/fs.test.js api/validation.test.js` in `plugins/plugin-studio/server` at the time this note was written.
- This note describes implementation status, not intended roadmap scope.

## Shipped Today

### Runtime and backend

- Plugin scaffold, manifest, commands, hook config, and launch scripts exist.
- `scripts/start.sh` enforces `node >= 18` and launches `server/index.js`.
- `server/index.js` serves `app/dist/`, probes for an available localhost port, writes a PID file, applies localhost-only CORS rules, and opens the browser.
- `/api/` returns runtime status used by the frontend health poll.
- `/api/fs/*` is implemented: tree, file read/write/create/delete, rename, and duplicate.
- `/api/validate/*` is implemented for plugin, hook, agent, and health validation.
- The validation engine is native to `plugin-studio`; it is not a runtime wrapper around `plugin-dev`.

### Shell chrome that is real

- The React/Vite app shell exists and loads from `app/dist/`.
- The 4-panel workbench layout is implemented: header, left rail, editor/preview workspace, AI rail, validation rail, and status strip.
- Tree rail mode cycling, workspace mode switching, command palette modal, toasts, runtime status polling, responsive bounds, resize handles, and layout persistence are implemented.

## Placeholder or Demo-Only Today

- The tree, open tabs, editor content, preview content, validation list, command-palette file results, and AI chat content are all hydrated from `app/src/lib/workbench-demo.ts` via `useWorkbenchDemoState.ts`.
- The editor pane is `EditorPlaceholder`, not Monaco, and it does not read or write real files.
- The preview pane is `PreviewPlaceholder`, not a renderer over real active-document content.
- The validation rail UI is not wired to `/api/validate/*`; `RUN ALL` currently triggers demo toast behavior.
- The AI rail is present as shell chrome, but its messages are canned local state; there is no `/api/ai/*` backend.
- The settings affordances are placeholders: the header `SETTINGS` button does not open a real panel, and `--settings` is not implemented end to end.
- `useServerStatus.ts` is the only frontend code currently calling live backend routes.

## Issue Ownership Map

| Issue | Missing capability owned by the issue | Current reality before that issue lands |
| --- | --- | --- |
| `#6` | Real plugin tree wired to `/api/fs/tree`, plus root validity/error states and scale handling | Tree rail UX/chrome is shipped, but `TreePlaceholder` still renders demo groups and demo files |
| `#7` | Monaco editor plus real file load/save wiring through `/api/fs/file` | Editor surface is `EditorPlaceholder` with static demo lines and fixed cursor text |
| `#8` | Real preview rendering for the active document | Preview surface is `PreviewPlaceholder` backed by canned preview blocks |
| `#9` | Validation rail wired to `/api/validate/*`, with running/result states and navigation | Validation backend is shipped, but the rail still uses `DEMO_VALIDATION_ISSUES` |
| `#10` | Truthful `/plugin-studio:open` behavior, path propagation, pre-flight/failure handling, launch UX | Command docs and launcher exist, but the server always opens the base URL; `[path]` and `--settings` are not wired through to the browser app |
| `#11` | QA and integration coverage for shell behavior, runtime smoke paths, viewport matrix, and cross-platform checks | Backend unit tests exist and pass; there is no app smoke suite or documented viewport/integration matrix in the plugin |
| `#12` | Real `/api/ai/*` REST API and request/response contracts | Only provider config preparation exists under `server/lib/ai/`; no AI routes are exposed |
| `#13` | AI chat UI wired to the backend with pending/error states and editor-apply flow | The AI drawer is shell chrome only; chat replies come from local demo state |
| `#18` | Multi-provider runtime abstraction and provider execution order | Provider constants/defaults exist, but there is no runtime implementation behind them |
| `#19` | Real settings UI for provider/runtime configuration and health | `commands/settings.md` exists, but the UI/settings flow is not implemented |
| `#20` | Public README/docs aligned to shipped reality, with screenshot/mockup and no overclaims | The current README still describes Monaco, live validation wiring, scaffolding, and `plugin-dev` dependency posture ahead of implementation |

## Practical Read of the Current State

- `plugin-studio` has real local runtime infrastructure and real backend foundations.
- The user-facing workbench chrome is substantially built.
- Most workbench content is still demo scaffolding until issues `#6`, `#7`, `#8`, `#9`, `#12`, `#13`, `#18`, and `#19` land.
- Public-facing documentation should not be used as implementation truth until `#20` is complete.
