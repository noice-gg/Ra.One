# v8.7.1 — Parser fix

- Fixed the Level 2 enemy drawing parser error at `scripts/game.gd:1043` by explicitly declaring `is_striker` as a `bool` and converting the dictionary value to a string before comparison.
- No gameplay behavior was intentionally changed.
- Godot runtime/parser validation was not available in the packaging environment; please open the project in Godot 4.7.2 and check the Debugger for any remaining errors.
