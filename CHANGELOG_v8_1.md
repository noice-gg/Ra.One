# v8.1 — Transparent Glitch Menu & Intro Music

## Menu visual update
- Replaced the rectangular title menu backing with a custom irregular clipped polygon inspired by the user's hand-drawn outline.
- Made the panel and menu-button fills approximately 50% transparent so the cinematic title art remains visible through the UI.
- Kept button labels crisp and readable while adding animated cyan/blue and red pixel glitch fragments to the hovered item.
- Added a dedicated `♫ MUSIC ON/OFF` button in the top-right corner.

## Music
- Included the user-provided `Ra-One-Humming-Ringtone.mp3` as the title/story intro music.
- The track starts on the title screen and loops while in title/story/settings/credits screens.
- The dedicated music toggle pauses/unpauses the intro track without muting other game audio.
- The intro track stops when gameplay begins.

## Validation
- ZIP integrity was checked after packaging.
- Godot runtime/parser validation was not available in the packaging environment; please test in Godot 4.7.2 before replacing the existing project.
