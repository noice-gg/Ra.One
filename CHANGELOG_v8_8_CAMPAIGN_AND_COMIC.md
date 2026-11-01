# v8.8 — Campaign progression, weapon workbench, comic prologue

- Added original four-panel cyberpunk comic art to the story intro.
- Rewrote the prologue around G.One building the Engine, granting an AI administrator access, the AI takeover, and the engineer being pulled into his own game.
- Menu theme is reserved for title/story/menu states; gameplay and boss loops are stopped. Boss arrival still has a stinger.
- Portal from Region 1 transitions directly into the Null Foundry without a level-clear screen, retains weapons/shards, raises max health by 35, heals the player, and saves a Region 2 checkpoint.
- Retry from death in Region 2 returns to that checkpoint instead of restarting Region 1.
- Increased regular enemy and boss health.
- Added Chaos Overlord reinforcements with a cap.
- Added X-key weapon cycling and a weapon workbench UI showing shard count, ownership, level, upgrade cost, and max level. Press E at the terminal to open; E again buys an upgrade; Esc closes.
- Added stronger narrative copy and live breach-status indicators to the title screen.

## Validation
Project and ZIP file structure checked. Godot executable was unavailable in the build environment, so the project has not been parser-tested or runtime-tested in Godot 4.7.2.
