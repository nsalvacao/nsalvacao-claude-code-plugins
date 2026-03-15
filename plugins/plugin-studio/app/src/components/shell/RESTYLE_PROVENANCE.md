# Plugin Studio Shell Restyle Provenance

The current shell implementation is based on the external prototype chosen as the visual north star:

- [`plugin-studio-shell-restyle-v1_3.html`](/mnt/d/GitHub/nsalvacao-claude-code-plugins/.dev/gemini-manual-restyle/plugin-studio-shell-2026-03-13/output_v1_3/plugin-studio-shell-restyle-v1_3.html)
- [`RESTYLE_NOTES_V1_3.md`](/mnt/d/GitHub/nsalvacao-claude-code-plugins/.dev/gemini-manual-restyle/plugin-studio-shell-2026-03-13/output_v1_3/RESTYLE_NOTES_V1_3.md)

This React port also incorporates a curated migration pass from the preserved antigravity sandbox:

- [`frontend_work/plugins/plugin-studio/app/src`](/mnt/d/GitHub/nsalvacao-claude-code-plugins/.dev/antigravity_frontend/frontend_work/plugins/plugin-studio/app/src)
- [`ai_handover_plugin_studio.md`](/mnt/d/GitHub/nsalvacao-claude-code-plugins/.dev/antigravity_frontend/context/ai_handover_plugin_studio.md)

Important implementation rule:

- The prototype is a design and interaction reference.
- The React shell ports the visual system and shell ergonomics, but does not import the standalone DOM code directly.
- `innerHTML`, inline `onclick`, `window.*` helpers, and standalone mock injections must stay out of production runtime code.
