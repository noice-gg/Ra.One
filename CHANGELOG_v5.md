# Ra.One: The Corrupted Engine — v5 changelog

## Focus: larger, exploratory Level 1

- Expanded Level 1 to a 2304 × 1632 world (72 × 51 32px cells).
- Added smooth camera follow and world-coordinate aiming.
- Replaced the micro-grid arena floor with pixel-art grass, winding sand paths, ancient stone plazas, water patches, and scattered pixel-art trees/rocks inspired by the Pygame v10 world.
- Added 12 security drones and delayed the Level 1 spider-mech boss until all drones are defeated.
- Fixed the shift-movement problem: Space now performs a single cooldown-controlled phase dash; Shift+left-click fires the Rail Blaster if acquired.
- Added projectile collision against obstacles and finite projectile lifetime; rail beam terminates at the first obstruction and only damages enemies along its unobstructed segment.
- Added enemy line-of-sight checks so drones do not shoot through solid obstacles.
- Kept the fog-of-war and persistent explored minimap, now scaled to the full world.
- Kept CGG algorithm demonstrations accessible with Tab.

## Validation status

- Project archive and file layout checked.
- This environment does not have Godot installed, so this build has not been run in Godot. Runtime behavior must be checked on the user's Ubuntu/Godot installation.
