# UI / Comic Update v9.0

- Replaced the title screen with a full-bleed illustrated title/menu image. The logo and menu labels are part of the art, so the renderer no longer draws a second logo or duplicate menu labels on top.
- Kept the title menu interactive with hitboxes aligned to START, SETTINGS, ARCHIVES, and EXIT. Hover only adds a restrained cyan outline.
- Replaced all four story illustrations with separate multi-panel manga pages: building the engine, integrating the AI, the AI takeover, and the engineer being pulled into the digital world.
- Story comic pages are aspect-fitted so their panel layouts are not stretched or squashed.
- Added explicit types for the previously reported `center`, `tip`, `foundry_lane`, and `path_y` inference issues.
- The title screen image contains the menu labels; audio mute/volume controls remain available from Settings.

Validation: ZIP integrity and source/artifact presence checked. Godot runtime/parser validation was not available in the build environment, so please run the project in Godot 4.7.2 to confirm scene behavior.
