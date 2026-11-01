# v6 — World & Combat Pass

- Replaced micro-grid technology textures with original pixel-art grass, sand, stone and water tiles.
- Added irregular ponds, winding trails, stone clearings, tree clusters, rocks and data flora.
- Increased Level 1 to 16 security drones. The spider-mech stays dormant until every drone is defeated.
- Added cached grid BFS routing so enemies can navigate around walls and cover.
- Added a boss radial projectile burst and aimed spread attack.
- Added a pulsing red corruption transition when the boss awakens, matching the Pygame v10 beat.
- Made water impassable and improved fog readability while retaining explored-area memory.

## Inspiration
Design lessons were taken from classic top-down adventure worlds and public Godot examples (biome identity, paths, landmarks, pathfinding and readable attack patterns). Their art/code are not copied; the new tiles and tree sprite were generated for this project.

## Validation
ZIP integrity checked. Godot was not available in the authoring environment, so this has not been runtime-tested.
