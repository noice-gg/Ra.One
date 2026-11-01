# Visual quality pass — Ra.One: The Corrupted Engine

This update focuses on the visual issues seen in the first running Godot build:
- Tight-cropped player sprite so transparent padding no longer makes G.One tiny.
- Larger drone and boss artwork, with a glow layer for readability.
- Textured industrial floor panels rather than a flat repeated grid.
- Layered server pillars, warning stripes, crates, boundary bulkheads and hazard lamps.
- Subtle sector color signatures, ambient pools and animated scanlines.
- Larger animated weapon pickups and a clearer ground shadow/halo for G.One.

## Import as a separate project
1. Stop the currently running game.
2. Extract this ZIP into a new folder.
3. In Godot Project Manager, click Import and select the extracted `project.godot`.
4. Open the project and run `scenes/main.tscn` with F6.

Keep the previous project as a backup. This update was generated and ZIP-checked, but it has not been run in the user's Godot runtime. If a parser error appears, send the exact message so it can be corrected before more features are added.
