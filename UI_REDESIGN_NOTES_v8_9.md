# v8.9 — Settings and Archives UI pass

## Scope
- Preserved `_draw_title()` and the main title screen artwork/layout/menu tiles.
- Rebuilt Settings as a layered cyberpunk configuration panel with distinct audio and display cards, active hover states, working menu-music and SFX sliders, mute state, fullscreen toggle, and a clear back action.
- Replaced the Archives paragraph screen with a four-chapter illustrated comic viewer. Each chapter uses a separate 16:9 illustration, shares the same outer frame, shows chapter progress, and supports Previous/Next, click-to-advance, Space/Enter, and Escape.
- The opening story starts a run after the fourth slide; viewing Archives returns to the title screen after the fourth slide.
- Removed automatic timed story advancement so players can read/view each comic panel at their own pace.
- Audio settings update AudioStreamPlayer volume in decibels using Godot's linear-to-dB conversion.

## Reference notes
- Godot's TextureRect documentation explains stretch modes and aspect-ratio-preserving image display; the chapter art has been prepared as separate 16:9 images for consistent panel fitting.
- Godot's AudioStreamPlayer documentation describes `volume_db` and converting linear slider values with `linear_to_db()`; settings sliders use this approach.

References:
- https://docs.godotengine.org/en/4.7/classes/class_texturerect.html
- https://docs.godotengine.org/en/4.7/classes/class_audiostreamplayer.html

## Validation status
- Checked that all four chapter image paths referenced by `game.gd` exist.
- ZIP integrity is checked after packaging.
- Godot 4.7.2 is not installed in this authoring environment, so the project still needs a local engine run to confirm parser/runtime behavior.
