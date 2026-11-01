# Ra.One: The Corrupted Engine — v8.7 Level 2: The Null Foundry

A focused visual/gameplay iteration for Godot 4.7.2. The goal is to keep the organic exploration and readability that worked in the Pygame prototype while giving the world a distinct corrupted-digital identity.

## What changed in v7

- Repainted terrain tiles with a coherent dark-teal / graphite / cyan / violet palette: corrupted organic ground, fractured circuit paths, data ruins, and dark energy water.
- Kept organic silhouettes, but tinted trees into bioluminescent data growth rather than ordinary green woodland.
- Added three hand-authored visual landmarks: **The Signal Shrine**, **Sunken Relay**, and **Fracture Grove**.
- Reduced the two oversized early-route structures and redesigned the remaining obstacles as broken relay ruins with chipped silhouettes, energy seams, antennae, status lights, and occasional labels.
- Replaced the generic boxed weapon pickup with four custom pixel-art weapon sprites. Pickups now have a pulsing beacon, orbiting arc, vertical signal, weapon name, and claim label.
- Upgraded projectile rendering with a layered plasma shell and white-hot core.
- Upgraded the Rail Blaster beam with a broad energy bloom, bright core, jagged ion arcs, side forks, and an impact flash.
- Softened the fog-of-war falloff so visibility feels less like a hard square cutout.
- Explicitly typed the terrain `on_path` expression as `bool` to avoid the parser error seen in the earlier project.

## Controls

- WASD / arrows: move
- Mouse: aim
- Left click: fire selected weapon
- Shift + left click: Rail Blaster
- Right click: Nova Core
- Space: dash
- E: upgrade at the Signal Shrine
- 1–4: select weapon slots
- Tab: CGG algorithm panel
- Esc: pause

## Important verification note

This archive has been edited and its ZIP structure is checked, but Godot 4.7.2 was not available in the authoring environment. Therefore the project has **not** been launched or runtime-tested here. Open it in Godot, run it, and report the first parser/runtime error if one appears. Test visuals and performance before treating this as a final submission build.

## Art direction

This is not a recreation of Pokémon, Champion's Island, Hyper Light Drifter, or any other existing game. It borrows high-level design lessons—readable routes, recognizable landmarks, distinct zones, strong color hierarchy, exploration rewards—and applies them to an original cyber-corrupted island setting.

### v7.1 gameplay polish
The latest v7.1 update improves player readability, uses randomized walkable drone spawns, fixes the boss's initial placement and blocked-target pathing edge case, reduces the number of intrusive relay structures, and reveals the animated extraction portal only after the Spider-Mech is defeated. Open the project in Godot 4.7.2 and test a full run; this environment cannot launch Godot to verify runtime behavior.


## Cinematic opening
This build opens on the new full-screen `assets/title_screen.png` artwork. **Start** launches a skippable four-card backstory sequence before Level 1. Settings includes audio mute and fullscreen toggles; Credits and Exit are functional. The previous generic slogan and `G.ONE PROTOCOL` footer were removed. See `TITLE_SCREEN_RESEARCH.md` for research links and notes for replacing the storyboard with a real video later.

## v8 cinematic opening
The title screen now uses `assets/title_screen.png` and a functional Start / Settings / Credits / Exit menu. Start launches a four-card story intro before gameplay. Click, Space, or Enter advances the cards; Escape returns to the title. Settings supports mute (`M`) and fullscreen (`F11`). The former generic tagline and G.ONE Protocol footer are removed. See `TITLE_SCREEN_RESEARCH.md` and `CHANGELOG_v8.md`.

The current story intro is a working storyboard rather than a video file, so the game remains playable before a custom backstory video is produced. The title wordmark is baked into the static artwork; no working Ethnocentric font file is bundled.

## v8.1 title menu and intro music update

The title menu now uses a custom irregular polygon panel inspired by the supplied sketch, with translucent panel/button fills and animated red/cyan pixel glitching on the hovered button. The user-provided `assets/Ra-One-Humming-Ringtone.mp3` plays and loops on the title/story screens. Use the top-right **MUSIC ON/OFF** button to mute or resume this track independently of other game audio. The music stops when gameplay starts.

See `CHANGELOG_v8_1.md` for details. Runtime testing still needs to be performed in Godot 4.7.2.


## v8.2 UI rebuild
The title background is now artwork-only. Logo, subtitle, menu buttons, hover glitches, and music control are drawn by code. The large enclosing polygon behind the menu has been removed. See `CHANGELOG_v8_2.md`.


## v8.3 logo restoration

The metallic RA.ONE wordmark and THE CORRUPTED ENGINE subtitle are restored as a separate transparent overlay at `assets/ra_one_wordmark.png`. The menu buttons remain interactive code-drawn elements, not part of the background image.

## v8.4 menu polish

The title menu now has a brighter layered cyan hover glow around the selected button. The right-side selection arrow and the small keyboard-navigation hint under the menu have been removed to keep the cinematic composition clean. See `CHANGELOG_v8_4.md`.

## v8.5 — Cinematic Smoke Hover

This update removes the small red/cyan glitch squares from menu hover. The selected tile now uses a stronger layered cyan-blue bloom, a pulsing glowing red left accent, and soft procedural smoke wisps drifting around the tile. Smoke texture is generated once at startup and reused, rather than creating new textures every frame. The RA.ONE wordmark, music toggle, and separate menu tiles are preserved. See `CHANGELOG_v8_5.md`.

## v8.6 Audio Overhaul
This build adds original synthesized sound effects and procedural ambient music. See `CHANGELOG_v8_6_AUDIO.md` for the complete cue list. Audio assets are in `assets/audio/`; `scripts/audio_manager.gd` manages SFX playback and gameplay/boss music transitions. Use the existing music toggle to mute/unmute the adaptive game music. Sound effects remain enabled when music is muted.


## v8.7 — Level 2: The Null Foundry

- Added a distinct second level with a steel-foundry palette, coolant pools, denser industrial cover, and three readable landmarks.
- Added two enemy roles: slower Foundry Sentinels and fast Foundry Strikers.
- Added the Chaos Overlord as the Level 2 boss, with a larger health pool, faster projectiles, and a wider radial attack.
- Added generated pixel-art enemy/boss sprites adapted from the supplied robot concepts.
- Level 1 victory now offers **Continue to Level 2**. The second level preserves remaining health, data, weapon ownership, and upgrades.
- The Level 2 extraction gate remains hidden until the Chaos Overlord is defeated.
- Added `LEVEL2_DESIGN.md` with progression notes and a pre-publication checklist.

### Testing status
The archive structure and required assets are checked, but Godot 4.7.2 was not available in this authoring environment, so the game has not been launched or runtime-tested. Run the full Level 1 → Level 2 route in Godot before using this as a release candidate. Before commercial publication, complete QA, performance/audio balancing, save/checkpoint handling, platform requirements, and title/IP clearance.


## v8.8 campaign update
See `CHANGELOG_v8_8_CAMPAIGN_AND_COMIC.md`. The story prologue now uses `assets/story/engine_origin_comic.png`. Controls: WASD move, mouse fire, Shift+left click rail blast, right click nova, Space dash, E open/purchase at workbench, X cycle weapons, 1–4 direct select, Tab CGG algorithm lab, Esc pause/close.

## v8.9 Settings and Archives UI

The title/start menu artwork and layout are intentionally preserved. Settings now has styled audio/display cards, working music/SFX volume controls, mute and fullscreen toggles, and a back action. Archives and the start-of-game intro share a four-chapter illustrated comic viewer with Previous/Next controls and no automatic timed page changes. See `UI_REDESIGN_NOTES_v8_9.md` for details and validation notes.


## v9.1 Title Menu Restoration

The title menu has been restored to the v8.6 implementation and artwork. The comic story pages remain from v9.0. See `TITLE_MENU_RESTORATION_v9_1.md` for details.


## v9.2 Combat balance

See `COMBAT_BALANCE_v9_2.md` for the updated health, three-level weapon damage, enemy damage, and medkit rules.
