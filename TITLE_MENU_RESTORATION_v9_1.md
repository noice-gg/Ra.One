# v9.1 Title Menu Restoration

- Restored the title-screen drawing implementation and button hitbox geometry from v8.6.
- Restored the v8.6 `assets/title_screen.png` background artwork and `assets/ra_one_wordmark.png` wordmark.
- The title screen once again draws the logo, transparent outlined START / SETTINGS / CREDITS / EXIT buttons, hover lighting, and top-right MUSIC ON/OFF control independently over the background.
- Kept the v9 comic-story page implementation and its four separate multi-panel chapter images.
- Explicit type fixes retained for `center`, `tip`, and `foundry_lane`.
- Packaging validation checks ZIP integrity only; Godot runtime/parser testing was not available in this environment.
