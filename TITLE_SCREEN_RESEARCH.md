# Cinematic Opening & Main Menu Research

## Implemented in this build
- Full-screen cinematic title artwork at `assets/title_screen.png`.
- Interactive Start / Settings / Credits / Exit menu, with mouse hover and keyboard navigation.
- Start opens a four-card narrative sequence; each card auto-advances after six seconds, and click/Space/Enter advances sooner. Escape returns to the title.
- The story sequence explains the Engine, the corruption, G.One, weapon recovery, the Spider-Mech, and extraction before gameplay begins.
- Settings supports master audio mute (`M`) and fullscreen toggle (`F11`).
- Removed the previous generic slogan and fake protocol/version footer.

## Design references researched
1. Godot's official title-screen guide recommends sketching the layout first and arranging content into clear containers. We applied the same hierarchy visually: title artwork, one compact menu panel, and a separate narrative sequence.
   - https://docs.godotengine.org/en/3.2/getting_started/step_by_step/ui_main_menu.html
2. Godot's `TextureRect` docs explain aspect-preserving image placement. This project uses a 16:9 generated background and draws it to the 1280x720 game viewport.
   - https://github.com/godotengine/godot-docs/blob/master/classes/class_texturerect.rst
3. Godot's `VideoStreamPlayer` documentation describes video playback. The opening currently uses a skippable storyboard sequence so it works without an external video file. When the creator's backstory video is ready, it can replace this sequence; Godot supports Ogg Theora (`.ogv`) natively in the documented setup.
   - https://docs.godotengine.org/en/4.5/classes/class_videostreamplayer.html
4. Ethnocentric is described by Typodermic as an all-caps, angular, wide display face suited to game logos. The supplied title artwork uses a rendered futuristic wordmark rather than embedding the font file. Typodermic's current license guidance says game/software embedding requires appropriate embedding rights, so check the exact license before bundling a working font in a distributed game.
   - https://typodermicfonts.com/ethnocentric/
   - https://typodermicfonts.com/license/

## Future video integration
- Create a short 30–60 second backstory video, ideally with voice-over, captions, and a sound design pass.
- Keep the video in a supported format and verify playback on the target operating systems. Godot's documented `VideoStreamPlayer` supports Ogg Theora (`.ogv`) without an add-on; other formats may require a GDExtension.
- Keep a Skip prompt visible throughout the video, and begin gameplay when playback finishes or the player skips.

## Validation note
The ZIP was checked for archive integrity. Godot was not available in the packaging environment, so the script has not been run through the Godot parser or runtime here. Please open the project in Godot 4.7.2 and test Start, all menu buttons, the story sequence, mute, fullscreen, and gameplay input.
