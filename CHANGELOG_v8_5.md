# v8.5 — Cinematic Smoke Hover

- Removed all red/cyan pixel-glitch rectangles from menu hover.
- Added a soft procedural cloud texture generated once at startup and reused during drawing.
- Added slow drifting cyan and muted red smoke wisps around the hovered tile.
- Intensified the selected tile's layered cyan-blue glow while keeping text sharp.
- Added a pulsing red accent strip with multiple glow widths and a bright core.
- Preserved the isolated RA.ONE logo, independent menu tiles, music toggle, and removed footer/arrow.

Runtime validation note: the project was packaged and ZIP-tested in an environment without the Godot executable. Open it in Godot 4.7.2 and check the title screen locally.
