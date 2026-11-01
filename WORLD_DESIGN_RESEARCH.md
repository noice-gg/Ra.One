# World & Combat Research Notes — Ra.One: The Corrupted Engine

Research checked: 18 October 2026. These are design and technical references, not assets to copy. Inspect each project's licence and asset provenance before reusing anything.

## Design direction

### 1. Build a place, not an obstacle field
The current Level 1 should read as a small, explorable island with a route and memorable locations. Use a main route, optional loops, hidden caches, and three or four landmarks visible from a distance. Every obstacle needs a reason to exist: relay shrine, collapsed bridge, sealed vault, corrupted grove, or extraction gate. Avoid anonymous rectangles scattered across the route.

### 2. A hybrid identity: organic forms + digital corruption
Keep the natural silhouette language that made the Pygame prototype feel inviting, but change the material story: dark teal soil, graphite/circuit paths, cyan data veins, violet corruption, black water with luminous edges, and trees that look like bioluminescent data organisms. The goal is contrast and depth—not a uniformly black map.

### 3. Distinct zones within one polished level
Suggested single-level progression:
- **Signal Verge** — readable starting grove, safe route, first Pulse Gun pickup.
- **Sunken Relay** — broken bridge, dark energy pool, small drone patrol.
- **Fracture Grove** — violet crystal growth, optional data caches, denser combat.
- **Server Cathedral** — large original silhouette and clear boss arena; the world visibly corrupts when the boss wakes.
- **Extraction Gate** — a visible objective landmark, locked until the encounter is complete.

### 4. Combat needs anticipation, impact, and recovery
For each weapon: clear pickup silhouette, a distinct projectile profile, a strong hit flash, short knockback/stun, and a readable cooldown. For big attacks: telegraph first, then fire, then a brief recovery window. Avoid visual noise that hides enemy attacks. Make the Rail Blaster feel like a high-energy event with a white-hot core, colored bloom, jagged ion forks, hit sparks, and a short camera shake. The beam should remain readable against both light and dark terrain.

## Open-source and official references

### Godot 2D lighting and shadows
Official documentation:
https://docs.godotengine.org/en/4.6/tutorials/2d/2d_lights_and_shadows.html

Useful concepts: CanvasModulate for ambient darkness; PointLight2D for weapon pickups, cores and projectiles; occluders for meaningful architecture. The docs also warn that larger lights affect more pixels and cost more, and mention additive sprites as a faster alternative for short-lived effects. For this project, prefer a few intentional lights over many large real-time lights.

### Godot TileMapLayer
Official documentation:
https://docs.godotengine.org/en/4.4/tutorials/2d/using_tilemaps.html

Useful concepts: reuse tilesets, separate terrain layers, use tile collision/occlusion/navigation where needed, and avoid drawing a large map as hundreds of independent scene nodes. This is a future architectural improvement; v7 keeps the existing custom drawing approach to minimize migration risk.

### FourShot — open-source top-down roguelike shooter
https://github.com/AltDual/FourShot

The project's description highlights rooms that must be cleared, minimap/exploration, progression upgrades, and a boss encounter. Useful design lesson: the combat space itself should communicate progression. Do not copy its rooms, assets, or code without reviewing the MIT licence and attribution requirements.

### 2D Top-Down Shooter — Godot / C#
https://github.com/bsmejko/2D-Top-Down-Shooter

Describes procedural maps, A* pathfinding, enemy variants, line-of-sight, object pooling, weapons and bosses. Useful technical ideas: reuse projectile/enemy objects when populations grow; keep navigation and combat responsibilities separate; use line-of-sight and different enemy roles. It is C# and is a reference architecture, not a drop-in GDScript solution.

### GodotGameDemo / Tiny Kingdom
https://github.com/MikaSwissRoll/GodotGameDemo

A Godot 4.7.2 top-down pixel-action demo with hand-authored arenas, terrain, vegetation, combat rooms, upgrades, and an elite battle. Useful lesson: combine handcrafted arena layouts with reusable environment functions. Its README says Tiny Swords assets are not included; do not assume those assets are redistributable.

### Action-RPG (Godot 4)
https://github.com/TariqBarnabas/Action-RPG

Useful systems reference for directional animation, collision separation, navigation, and scene organization. Its README lists the sprite assets as CC BY-NC-SA 4.0, so those art assets are **not suitable for a commercial release** unless permission/licensing changes.

### Hyper Light Drifter — worldbuilding interview
https://unwinnable.com/2015/12/02/interview-with-alex-preston-the-creator-of-hyper-light-drifter/

Useful high-level reference for environmental storytelling and letting the world communicate through composition. Treat this as inspiration for visual narrative, not a template to reproduce.

## High-impact additions to prioritize

1. **Landmark readability:** make the Signal Shrine, Sunken Relay, Fracture Grove and boss arena visually distinct at a glance.
2. **Weapon readability:** every weapon pickup must be recognizable before the player is close enough to collect it.
3. **Combat readability:** color-code player, enemy and boss attacks; use short telegraphs before dangerous attacks.
4. **Boss phase change:** after the drones fall, darken the sky/terrain, shift the palette toward red-violet, animate the boss entrance, and alter attack patterns.
5. **Exploration rewards:** put optional data caches in side paths, not only along the main path.
6. **Sound and camera feedback:** short hit-stop, controlled screen shake, weapon-specific audio, and a boss arrival sting. Add these after the core gameplay is stable.
7. **Performance:** profile first. Prefer a small number of carefully placed PointLight2D nodes or additive sprite glows over a light on every particle. Consider TileMapLayer and pooling in a later refactor.

## Commercial release / asset hygiene

Open-source game code does not automatically make its sprites, music, fonts, or third-party packs commercially reusable. Keep a per-asset source and licence inventory. Before publishing, replace placeholder or uncertain assets, use original branding, and get appropriate advice on the name “Ra.One” and related marks.
