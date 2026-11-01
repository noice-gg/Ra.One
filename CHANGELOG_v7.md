# v7 — Corrupted Island Art Direction

- Reworked floor tile palette to dark teal organic ground, fractured graphite circuit paths, data ruins, and dark energy water.
- Added original pixel-art pickup sprites for Pulse Gun, Rail Blaster, Laser Blade, and Nova Core.
- Weapon pickups now use colored beacons, orbiting arcs, weapon names, and claim labels.
- Added layered plasma bolts and a lightning-fork Rail Blaster effect.
- Added Signal Shrine, Sunken Relay, and Fracture Grove landmarks.
- Reframed structures as relay ruins and reduced oversized early-route blockers.
- Softened fog-of-war edge.
- Fixed explicit `bool` type annotation for `on_path`.
- Added `WORLD_DESIGN_RESEARCH.md` with open-source/official references and art direction priorities.

Verification: archive structure can be checked, but Godot runtime testing was unavailable in the authoring environment.

## v7.1 gameplay corrections
- Increased the player sprite draw size to improve readability during combat.
- Replaced the dense set of repeated rectangular obstacles with fewer, more widely spaced signal pylons and relay remnants.
- Randomized all 16 drone spawn positions on every new run, selecting only walkable cells and spacing enemies apart.
- Fixed the boss spawn so it appears in a clear region rather than inside a relay structure; it now has higher health and movement speed.
- Added nearest-walkable-goal fallback in pathfinding so enemies do not repeatedly try to path into a blocked tile near the player.
- The extraction gate is hidden until the Spider-Mech is defeated, then reveals as an animated cyan/violet portal with rotating rings, energy ribbons and sparks.
- Reworked the remaining structures with chipped silhouettes and offset conduits to reduce the generic storage-container appearance.
- Runtime validation is still required in Godot 4.7.2; no Godot executable was available in the authoring environment.
