# v8 — Cinematic Opening

## Main menu
- Replaced the plain grid title screen with a full-screen cinematic cyberpunk title image at `assets/title_screen.png`.
- Kept the RA.ONE wordmark and THE CORRUPTED ENGINE subtitle as part of the rendered logo artwork.
- Added a high-contrast interactive menu panel with Start, Settings, Credits, and Exit.
- Added mouse hover and keyboard Up/Down + Enter navigation.
- Removed the old `CLICK TO START`, `Explore the dark network...`, and `G.ONE PROTOCOL • GODOT 4.7.2` copy.

## Story opening
- Start now launches a four-part, skippable backstory sequence before Level 1.
- Each story card auto-advances after six seconds; click, Space, or Enter advances immediately.
- Escape returns to the title screen.
- The sequence establishes the Engine, the corruption, G.One, the weapon objective, Spider-Mech, and extraction gate.
- The storyboard can be replaced with a real video when the creator's video is ready.

## Settings and credits
- Settings supports master audio mute/unmute and fullscreen/windowed mode.
- Credits screen added; Exit closes the game.

## Licensing note
- The title is rendered as static artwork. The actual Ethnocentric font file is not bundled. Typodermic's current guidance distinguishes static desktop artwork from embedding a working font in a game; obtain the appropriate embedding rights if the actual font is later shipped in the game.

## Validation
- ZIP archive integrity checked after packaging.
- Godot 4.7.2 was not available in the packaging environment, so runtime/parser validation must be completed in the user's Godot editor.
