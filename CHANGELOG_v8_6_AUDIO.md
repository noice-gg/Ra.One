# v8.6 — Full Audio Pass

## New original audio
All effects in `assets/audio/` were synthesized specifically for this project and are shipped as OGG files; no external copyrighted sound packs are required.

- Menu hover and selection
- Player footsteps, dash, and damage impact
- Pulse Gun, Rail Blaster, Laser Blade, and Nova Core sounds
- Drone firing, taking damage, and destruction
- Boss arrival stinger, boss theme, attacks, damage, and defeat
- Data shard collection, weapon acquisition, and weapon upgrades
- Extraction gate activation, victory cue, and game-over cue
- Two procedural 32-second ambient music loops: gameplay and boss encounter

## Integration
A new `scripts/audio_manager.gd` handles sound-effect overlap with a small player pool, limits repeated rapid-fire/footstep cues, switches music when the boss arrives or falls, and follows the existing music mute setting. Gameplay event hooks were added in `scripts/game.gd`.

## Verification note
The archive and asset paths can be checked locally, but this environment does not have Godot installed, so the project has not been parser-tested or played in the Godot runtime. Please launch the project in Godot 4.7.2 and test the full loop, especially boss music transitions and audio levels.
