extends Node

const AUDIO_ROOT := "res://assets/audio/"
const MUSIC_TRACKS := {
	"gameplay": "gameplay_ambience",
	"boss": "boss_theme"
}

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var current_music := ""
var music_muted := false
var last_played: Dictionary = {}
var next_player := 0
var music_volume_linear: float = 0.80
var sfx_volume_linear: float = 0.85

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "AdaptiveGameMusic"
	music_player.bus = "Master"
	music_player.volume_db = -13.0 + linear_to_db(maxf(music_volume_linear, 0.001))
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)
	for i in range(12):
		var player := AudioStreamPlayer.new()
		player.name = "SFX_%02d" % i
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)
	for key in ["menu_hover", "menu_select", "footstep", "dash", "player_hit", "pulse_fire", "rail_fire", "blade_swing", "nova_blast", "drone_fire", "drone_hit", "drone_death", "boss_stinger", "boss_fire", "boss_hit", "boss_death", "shard_collect", "weapon_collect", "upgrade", "gate_open", "victory", "game_over"]:
		sfx_streams[key] = load(AUDIO_ROOT + key + ".ogg")

func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	if not sfx_streams.has(sound_name) or sfx_streams[sound_name] == null:
		return
	# Prevent frame-rate-triggered attacks from turning into an unlistenable wall of sound.
	var cooldown := 0.0
	if sound_name == "footstep": cooldown = 0.16
	elif sound_name == "pulse_fire": cooldown = 0.075
	elif sound_name == "drone_fire": cooldown = 0.12
	elif sound_name == "boss_fire": cooldown = 0.12
	var now := Time.get_ticks_msec() / 1000.0
	if cooldown > 0.0 and now - float(last_played.get(sound_name, -100.0)) < cooldown:
		return
	last_played[sound_name] = now
	var player: AudioStreamPlayer = sfx_players[next_player]
	next_player = (next_player + 1) % sfx_players.size()
	player.stop()
	player.stream = sfx_streams[sound_name]
	player.volume_db = volume_db + linear_to_db(maxf(sfx_volume_linear, 0.001))
	player.play()

func play_music(track_name: String) -> void:
	if not MUSIC_TRACKS.has(track_name):
		return
	if current_music == track_name and music_player.playing:
		return
	current_music = track_name
	music_player.stop()
	var stream: AudioStream = load(AUDIO_ROOT + str(MUSIC_TRACKS[track_name]) + ".ogg")
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	music_player.stream = stream
	music_player.stream_paused = music_muted
	if not music_muted:
		music_player.play()

func set_music_volume(value: float) -> void:
	music_volume_linear = clampf(value, 0.0, 1.0)
	music_player.volume_db = -40.0 if music_volume_linear <= 0.001 else -13.0 + linear_to_db(music_volume_linear)

func set_sfx_volume(value: float) -> void:
	sfx_volume_linear = clampf(value, 0.0, 1.0)

func set_music_muted(muted: bool) -> void:
	music_muted = muted
	music_player.stream_paused = muted
	if not muted and current_music != "" and not music_player.playing:
		music_player.play()

func stop_music() -> void:
	music_player.stop()
	current_music = ""

func _on_music_finished() -> void:
	if current_music != "" and not music_muted and music_player.stream != null:
		music_player.play()
