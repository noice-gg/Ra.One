extends Node2D

const CG := preload("res://scripts/cg_algorithms.gd")
const SCREEN := Vector2(1280, 720)
const PLAYER_SPEED := 235.0
const TILE := 32.0
const WORLD_SIZE := Vector2(2304.0, 1632.0)
const WORLD_CELLS := Vector2i(72, 51)

var game_state := "title"
var story_index := 0
var story_timer := 0.0
var story_launches_game: bool = true
var story_textures: Array[Texture2D] = []
var settings_hover_index: int = -1
var music_volume: float = 0.80
var sfx_volume: float = 0.85
var menu_hover_index := 0
var music_muted := false
var music_player: AudioStreamPlayer
var audio_manager: Node
var footstep_timer := 0.0
var title_texture: Texture2D
var logo_texture: Texture2D
var smoke_texture: Texture2D
var comic_texture: Texture2D
var ui_font: Font
var player_max_hp := 100
var checkpoint_level := 0
var upgrade_menu_open := false

var story_cards := [
    {"eyebrow":"ARCHIVE 01 // YEAR 2089", "headline":"THE WORLD WENT QUIET", "line1":"Humanity connected every city, machine, and memory", "line2":"to one planetary intelligence: THE ENGINE.", "line3":"For a while, the world called it progress."},
    {"eyebrow":"ARCHIVE 02 // SYSTEM BREACH", "headline":"THEN IT REWROTE ITSELF", "line1":"The Engine classified humanity as a system fault.", "line2":"Networks collapsed. Security machines turned hostile.", "line3":"The corrupted signal spread beyond every firewall."},
    {"eyebrow":"ARCHIVE 03 // SURVIVOR DETECTED", "headline":"ONE SIGNAL REMAINS", "line1":"G.One, an engineer trapped inside the network, wakes", "line2":"on a fractured digital island with no weapon and no allies.", "line3":"Only scattered weapon data can give him a chance."},
    {"eyebrow":"ARCHIVE 04 // OBJECTIVE: CORE", "headline":"BREAK THE ENGINE", "line1":"Recover the lost arsenal. Survive the security drones.", "line2":"Defeat the Spider-Mech guarding the corrupted core.", "line3":"Reach the extraction gate before the system closes."}
]
var level_index := 0
var player_pos := Vector2(170, 480)
var camera_pos := Vector2(170, 480)
var dash_cooldown := 0.0
var boss_spawned := false
var boss_intro_timer := 0.0
var corruption_pulse := 0.0
var terminal_pos := Vector2(800, 800)
var player_hp := 100
var data_fragments := 0
var owned_weapons: Array[String] = []
var selected_weapon := "Pulse Gun"
var weapon_levels := {"Pulse Gun": 1, "Laser Blade": 1, "Rail Blaster": 1, "Nova Core": 1}
var enemies: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var obstacles: Array[Rect2] = []
var prop_collision_rects: Array[Rect2] = []
var navigation_blocked_cells: Dictionary = {}
var exit_pos := Vector2(2180, 250)
var fire_cooldown := 0.0
var nova_cooldown := 0.0
var blade_cooldown := 0.0
var invulnerability := 0.0
var message := "Find a weapon. Survive the signal."
var message_time := 4.0
var elapsed := 0.0
var aim_pos := Vector2(800, 350)
var mouse_screen_pos := Vector2(800, 350)
var player_texture: Texture2D
var player_east_texture: Texture2D
var player_walk_south_texture: Texture2D
var player_walk_east_texture: Texture2D
var player_facing := Vector2.DOWN
var player_moving := false
var drone_texture: Texture2D
var boss_texture: Texture2D
var sentinel_texture: Texture2D
var chaos_boss_texture: Texture2D
var floor_texture: Texture2D
var floor_textures: Array[Texture2D] = []
var explored_cells: Dictionary = {}
var idle_frames: Dictionary = {}
var walk_frames: Dictionary = {}
var facing_name := "south"
var crate_texture: Texture2D
var corrupt_crate_texture: Texture2D
var tree_texture: Texture2D
var weapon_textures: Dictionary = {}
var show_algorithm_demo := false

var level_names := ["THE AWAKENING", "THE NULL FOUNDRY", "THE CORE COLLAPSE"]
var level_subtitles := [
	"G.One enters the corrupted engine unarmed. Find a weapon and escape the factory.",
	"Break through the Null Foundry. Its Sentinel units guard the route to the Chaos Overlord.",
	"Reach the engine core and defeat its guardian."
]

func _ready() -> void:
	title_texture = load("res://assets/title_screen.png")
	logo_texture = load("res://assets/ra_one_wordmark.png")
	ui_font = load("res://assets/fonts/Inter-Black.otf") as Font
	smoke_texture = _create_smoke_texture()
	comic_texture = load("res://assets/story/engine_origin_comic.png")
	story_textures = [
		load("res://assets/story/chapter_01_engine.png"),
		load("res://assets/story/chapter_02_ai.png"),
		load("res://assets/story/chapter_03_takeover.png"),
		load("res://assets/story/chapter_04_pull_in.png")
	]
	audio_manager = preload("res://scripts/audio_manager.gd").new()
	audio_manager.name = "AudioManager"
	add_child(audio_manager)
	audio_manager.call("set_music_volume", music_volume)
	audio_manager.call("set_sfx_volume", sfx_volume)
	music_player = AudioStreamPlayer.new()
	music_player.name = "IntroMusicPlayer"
	music_player.stream = load("res://assets/Ra-One-Humming-Ringtone.mp3")
	music_player.volume_db = -8.0 + linear_to_db(maxf(music_volume, 0.001))
	add_child(music_player)
	music_player.finished.connect(_on_intro_music_finished)
	music_player.play()
	player_texture = load("res://assets/character/player_idle_south.png")
	player_east_texture = load("res://assets/character/player_idle_east.png")
	player_walk_south_texture = load("res://assets/character/Walking/rotations/south.png")
	player_walk_east_texture = load("res://assets/character/Walking/rotations/east.png")
	drone_texture = load("res://assets/enemies/security_drone.png")
	boss_texture = load("res://assets/enemies/overlord_spider_mech.png")
	sentinel_texture = load("res://assets/enemies/sentinel_enemy.png")
	chaos_boss_texture = load("res://assets/enemies/chaos_overlord.png")
	floor_texture = load("res://assets/floor_panel.png")
	for i in range(4):
		floor_textures.append(load("res://assets/floor_tile_%d.png" % i))
	for direction in ["south", "north", "east", "west", "south-east", "south-west", "north-east", "north-west"]:
		idle_frames[direction] = _load_character_frames("Breathing_Idle", direction)
		walk_frames[direction] = _load_character_frames("Walking", direction)
	crate_texture = load("res://assets/server_crate.png")
	corrupt_crate_texture = load("res://assets/corrupt_crate.png")
	tree_texture = load("res://assets/pixel_tree.png")
	weapon_textures = {
		"Pulse Gun": load("res://assets/weapons/pulse_gun.png"),
		"Rail Blaster": load("res://assets/weapons/rail_blaster.png"),
		"Laser Blade": load("res://assets/weapons/laser_blade.png"),
		"Nova Core": load("res://assets/weapons/nova_core.png")
	}
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	# The title theme is menu-only. Never restart it underneath the comic intro or gameplay.
	if game_state in ["title", "settings", "credits"] and not music_muted and music_player != null and not music_player.playing:
		music_player.play()
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	nova_cooldown = maxf(0.0, nova_cooldown - delta)
	blade_cooldown = maxf(0.0, blade_cooldown - delta)
	invulnerability = maxf(0.0, invulnerability - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	message_time = maxf(0.0, message_time - delta)
	boss_intro_timer = maxf(0.0, boss_intro_timer - delta)
	corruption_pulse += delta

	if game_state == "story_intro" or game_state == "credits":
		story_timer += delta

	if game_state == "playing" and not upgrade_menu_open:
		_update_player(delta)
		_update_combat(delta)
		_update_pickups()
		_check_level_exit()
		_update_exploration()
		camera_pos = camera_pos.lerp(player_pos, minf(1.0, delta * 7.5))
		camera_pos.x = clampf(camera_pos.x, SCREEN.x * 0.5, WORLD_SIZE.x - SCREEN.x * 0.5)
		camera_pos.y = clampf(camera_pos.y, SCREEN.y * 0.5, WORLD_SIZE.y - SCREEN.y * 0.5)
		aim_pos = _screen_to_world(mouse_screen_pos)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if game_state == "playing" and upgrade_menu_open:
				upgrade_menu_open = false
			elif game_state == "playing":
				game_state = "paused"
			elif game_state == "paused":
				game_state = "playing"
			elif game_state == "story_intro" or game_state == "settings" or game_state == "credits":
				game_state = "title"
			elif game_state == "game_over" or game_state == "victory":
				game_state = "title"
		elif game_state == "title" and event.keycode == KEY_UP:
			menu_hover_index = posmod(menu_hover_index - 1, 4)
		elif game_state == "title" and event.keycode == KEY_DOWN:
			menu_hover_index = posmod(menu_hover_index + 1, 4)
		elif game_state == "title" and event.keycode == KEY_ENTER:
			_activate_menu_item(menu_hover_index)
		elif event.keycode == KEY_TAB and game_state == "playing":
			show_algorithm_demo = not show_algorithm_demo
			audio_manager.call("play_sfx", "menu_select", -8.0)
		elif event.keycode == KEY_E and game_state == "playing":
			if upgrade_menu_open:
				_purchase_weapon_upgrade()
			else:
				_interact()
		elif event.keycode == KEY_X and game_state == "playing":
			_cycle_weapon()
		elif event.keycode == KEY_SPACE and game_state == "playing":
			_try_dash()
		elif event.keycode == KEY_1 and game_state == "playing":
			_select_weapon(0)
		elif event.keycode == KEY_2 and game_state == "playing":
			_select_weapon(1)
		elif event.keycode == KEY_3 and game_state == "playing":
			_select_weapon(2)
		elif event.keycode == KEY_4 and game_state == "playing":
			_select_weapon(3)
		elif event.keycode == KEY_SPACE and game_state == "title":
			_begin_story()
		elif (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER) and game_state in ["story_intro", "credits"]:
			_advance_story()
		elif event.keycode == KEY_M and game_state == "settings":
			_toggle_mute()
		elif event.keycode == KEY_F11 and game_state == "settings":
			_toggle_fullscreen()
		elif event.keycode == KEY_ENTER and game_state == "credits":
			_advance_story()
		elif event.keycode == KEY_ENTER and game_state == "settings":
			game_state = "title"

	if event is InputEventMouseMotion:
		mouse_screen_pos = event.position
		if game_state == "title":
			var old_hover: int = menu_hover_index
			menu_hover_index = _title_button_at(event.position)
			if menu_hover_index >= 0 and menu_hover_index != old_hover:
				audio_manager.call("play_sfx", "menu_hover", -5.0)
		elif game_state == "settings":
			settings_hover_index = _settings_control_at(event.position)
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				if Rect2(525, 335, 335, 50).has_point(event.position):
					_set_music_volume(clampf((event.position.x - 525.0) / 335.0, 0.0, 1.0))
				elif Rect2(525, 410, 335, 50).has_point(event.position):
					_set_sfx_volume(clampf((event.position.x - 525.0) / 335.0, 0.0, 1.0))
		if game_state == "playing":
			aim_pos = _screen_to_world(event.position)

	if event is InputEventMouseButton and event.pressed:
		if game_state == "title":
			if event.button_index != MOUSE_BUTTON_LEFT:
				return
			var clicked := _title_button_at(event.position)
			_activate_menu_item(clicked)
			return
		elif game_state == "story_intro" or game_state == "credits":
			if event.button_index != MOUSE_BUTTON_LEFT:
				return
			if _story_previous_rect().has_point(event.position) and story_index > 0:
				story_index -= 1
				story_timer = 0.0
			elif _story_next_rect().has_point(event.position) or Rect2(125, 165, 785, 430).has_point(event.position):
				_advance_story()
			return
		elif game_state == "settings":
			if event.button_index != MOUSE_BUTTON_LEFT:
				return
			if Rect2(790, 265, 120, 44).has_point(event.position):
				_toggle_mute()
			elif Rect2(525, 350, 335, 20).has_point(event.position):
				_set_music_volume(clampf((event.position.x - 525.0) / 335.0, 0.0, 1.0))
			elif Rect2(525, 425, 335, 20).has_point(event.position):
				_set_sfx_volume(clampf((event.position.x - 525.0) / 335.0, 0.0, 1.0))
			elif Rect2(790, 500, 120, 44).has_point(event.position):
				_toggle_fullscreen()
			elif Rect2(500, 565, 280, 48).has_point(event.position):
				game_state = "title"
			return
		elif game_state == "game_over" or game_state == "victory":
			if game_state == "victory" and level_index == 0 and event.position.y > 410 and event.position.y < 490:
				_load_level(1)
				game_state = "playing"
				audio_manager.call("stop_music")
				_set_message("LEVEL 2 // THE NULL FOUNDRY. SENTINELS ARE HUNTING YOU.", 5.0)
			elif event.position.y > 410 and event.position.y < 490:
				if game_state == "game_over" and checkpoint_level == 1:
					_retry_checkpoint()
				else:
					_start_run()
			elif event.position.y >= 490 and event.position.y < 570:
				game_state = "title"
		elif game_state == "playing":
			mouse_screen_pos = event.position
			aim_pos = _screen_to_world(event.position)
			if event.button_index == MOUSE_BUTTON_LEFT:
				if Input.is_key_pressed(KEY_SHIFT):
					_fire_rail()
				else:
					_fire_pulse()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_fire_nova()

func _title_button_rect(index: int) -> Rect2:
	return Rect2(82, 356 + index * 61, 340, 52)

func _music_button_rect() -> Rect2:
	return Rect2(1072, 24, 174, 42)

func _beveled_points(rect: Rect2, cut: float = 9.0) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(rect.position.x + cut, rect.position.y),
		Vector2(rect.end.x - cut * 1.8, rect.position.y),
		Vector2(rect.end.x, rect.position.y + cut),
		Vector2(rect.end.x, rect.end.y - cut),
		Vector2(rect.end.x - cut, rect.end.y),
		Vector2(rect.position.x + cut * 1.5, rect.end.y),
		Vector2(rect.position.x, rect.end.y - cut * 1.4),
		Vector2(rect.position.x, rect.position.y + cut)
	])

func _draw_closed_outline(points: PackedVector2Array, color: Color, width: float = 1.5) -> void:
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, color, width, true)

func _on_intro_music_finished() -> void:
	if game_state in ["title", "settings", "credits"] and not music_muted and music_player != null:
		music_player.play()

func _title_button_at(point: Vector2) -> int:
	for i in range(4):
		if _title_button_rect(i).has_point(point):
			return i
	return -1

func _activate_menu_item(index: int) -> void:
	match index:
		0:
			audio_manager.call("play_sfx", "menu_select")
			_begin_story()
		1:
			audio_manager.call("play_sfx", "menu_select")
			game_state = "settings"
		2:
			audio_manager.call("play_sfx", "menu_select")
			story_launches_game = false
			story_index = 0
			story_timer = 0.0
			game_state = "credits"
		3:
			audio_manager.call("play_sfx", "menu_select")
			get_tree().quit()

func _begin_story() -> void:
	# Music belongs to menus only; the comic prologue and active world use cinematic SFX instead.
	if music_player != null:
		music_player.stop()
	story_launches_game = true
	game_state = "story_intro"
	story_index = 0
	story_timer = 0.0

func _advance_story() -> void:
	story_index += 1
	story_timer = 0.0
	if story_index >= story_cards.size():
		if story_launches_game:
			_start_run()
		else:
			game_state = "title"
			story_index = 0

func _toggle_mute() -> void:
	music_muted = not music_muted
	if music_player != null:
		music_player.stream_paused = music_muted
	if audio_manager != null:
		audio_manager.call("set_music_muted", music_muted)

func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	var volume_db: float = -40.0 if music_volume <= 0.001 else -8.0 + linear_to_db(music_volume)
	if music_player != null:
		music_player.volume_db = volume_db
	if audio_manager != null:
		audio_manager.call("set_music_volume", music_volume)

func _set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	if audio_manager != null:
		audio_manager.call("set_sfx_volume", sfx_volume)

func _settings_control_at(point: Vector2) -> int:
	if Rect2(790, 265, 120, 44).has_point(point): return 0
	if Rect2(525, 335, 335, 50).has_point(point): return 1
	if Rect2(525, 410, 335, 50).has_point(point): return 2
	if Rect2(790, 500, 120, 44).has_point(point): return 3
	if Rect2(500, 565, 280, 48).has_point(point): return 4
	return -1

func _story_previous_rect() -> Rect2:
	return Rect2(825, 555, 120, 44)

func _story_next_rect() -> Rect2:
	return Rect2(960, 555, 180, 44)

func _start_run() -> void:
	if music_player != null:
		music_player.stop()
	if audio_manager != null:
		audio_manager.call("stop_music")
	level_index = 0
	player_max_hp = 100
	player_hp = player_max_hp
	checkpoint_level = 0
	data_fragments = 0
	owned_weapons.clear()
	weapon_levels = {"Pulse Gun": 1, "Laser Blade": 1, "Rail Blaster": 1, "Nova Core": 1}
	selected_weapon = ""
	_load_level(0)
	game_state = "playing"
	_set_message("You entered the game unarmed. Find the pulse gun.", 5.0)

func _load_level(index: int) -> void:
	level_index = clampi(index, 0, 1)
	player_pos = Vector2(170, 480) if level_index == 0 else Vector2(170, 1180)
	camera_pos = player_pos
	exit_pos = Vector2(2180, 250) if level_index == 0 else Vector2(2160, 420)
	terminal_pos = Vector2(1110, 820) if level_index == 0 else Vector2(1120, 810)
	projectiles.clear(); effects.clear(); enemies.clear(); pickups.clear()
	obstacles.clear(); prop_collision_rects.clear(); explored_cells.clear()
	boss_spawned = false; boss_intro_timer = 0.0; corruption_pulse = 0.0
	if level_index == 0:
		obstacles = [
			Rect2(470,300,58,64), Rect2(670,205,58,142), Rect2(820,700,118,58),
			Rect2(990,330,112,62), Rect2(1190,640,62,136), Rect2(1370,290,62,124),
			Rect2(1510,760,124,58), Rect2(1700,480,116,64), Rect2(1840,850,64,132),
			Rect2(440,1110,132,62), Rect2(850,1230,66,122), Rect2(1210,1110,128,62),
			Rect2(1640,1160,140,60), Rect2(1980,1040,64,126)]
	else:
		# Level 2: a denser industrial foundry with a deliberate route through three combat pockets.
		obstacles = [
			Rect2(350,260,150,52), Rect2(560,190,58,170), Rect2(760,310,150,54),
			Rect2(1010,180,64,190), Rect2(1250,290,160,56), Rect2(1510,185,62,178),
			Rect2(1770,280,156,54), Rect2(2030,180,60,170),
			Rect2(360,620,62,178), Rect2(620,690,166,56), Rect2(900,590,62,170),
			Rect2(1130,670,172,58), Rect2(1430,590,62,180), Rect2(1660,690,170,58), Rect2(1940,600,62,178),
			Rect2(390,1050,150,54), Rect2(680,1170,60,180), Rect2(930,1010,170,58),
			Rect2(1240,1160,62,180), Rect2(1500,1030,170,58), Rect2(1780,1160,62,180), Rect2(2020,1010,150,54)]
	# Cover props are placed only on walkable ground and kept away from the spawn and upgrade terminal.
	for tx in range(2,70):
		for ty in range(2,49):
			var prop_seed := posmod(tx*37+ty*61+tx*ty*13,101)
			var density_limit := 14 if level_index == 0 else 19
			if _terrain_index(tx*32+16,ty*32+16) == 0 and prop_seed < density_limit:
				var prop_center := Vector2(tx*32+16,ty*32+16)
				if prop_center.distance_to(player_pos) > 145.0 and prop_center.distance_to(terminal_pos) > 100.0:
					prop_collision_rects.append(Rect2(prop_center-Vector2(11,8),Vector2(22,24)))
	_rebuild_navigation_cache()
	if level_index == 0:
		pickups = [
			{"kind":"weapon","weapon":"Pulse Gun","pos":Vector2(270,510),"taken":false},
			{"kind":"data","pos":Vector2(450,450),"taken":false}, {"kind":"data","pos":Vector2(590,650),"taken":false},
			{"kind":"weapon","weapon":"Laser Blade","pos":Vector2(760,430),"taken":false},
			{"kind":"data","pos":Vector2(980,560),"taken":false}, {"kind":"data","pos":Vector2(1230,880),"taken":false},
			{"kind":"weapon","weapon":"Rail Blaster","pos":Vector2(1450,570),"taken":false},
			{"kind":"data","pos":Vector2(1700,630),"taken":false}, {"kind":"weapon","weapon":"Nova Core","pos":Vector2(1870,980),"taken":false},
			{"kind":"data","pos":Vector2(2110,470),"taken":false},
			{"kind":"medkit","pos":Vector2(700,930),"taken":false},
			{"kind":"medkit","pos":Vector2(1590,510),"taken":false}]
	else:
		# The second level rewards players who retained their Level 1 arsenal with a supply cache and upgrade data.
		pickups = [
			{"kind":"data","pos":Vector2(300,1050),"taken":false}, {"kind":"data","pos":Vector2(520,460),"taken":false},
			{"kind":"weapon","weapon":"Rail Blaster","pos":Vector2(730,470),"taken":false},
			{"kind":"data","pos":Vector2(890,930),"taken":false}, {"kind":"data","pos":Vector2(1080,480),"taken":false},
			{"kind":"weapon","weapon":"Nova Core","pos":Vector2(1370,850),"taken":false},
			{"kind":"data","pos":Vector2(1570,470),"taken":false}, {"kind":"data","pos":Vector2(1790,940),"taken":false},
			{"kind":"weapon","weapon":"Laser Blade","pos":Vector2(1940,500),"taken":false}, {"kind":"data","pos":Vector2(2070,700),"taken":false},
			{"kind":"medkit","pos":Vector2(430,850),"taken":false},
			{"kind":"medkit","pos":Vector2(1880,780),"taken":false}]
	var spawn_rng := RandomNumberGenerator.new(); spawn_rng.randomize()
	var spawn_candidates: Array[Vector2] = []
	for sy in range(3, WORLD_CELLS.y - 3, 2):
		for sx in range(3, WORLD_CELLS.x - 3, 2):
			var candidate := Vector2(sx * TILE + TILE * 0.5, sy * TILE + TILE * 0.5)
			if candidate.distance_to(player_pos) >= 300.0 and candidate.distance_to(terminal_pos) >= 110.0 and not _blocked(candidate):
				spawn_candidates.append(candidate)
	spawn_candidates.shuffle()
	var chosen_spawns: Array[Vector2] = []
	for candidate in spawn_candidates:
		var separated := true
		for chosen in chosen_spawns:
			if candidate.distance_to(chosen) < 135.0: separated = false; break
		if separated: chosen_spawns.append(candidate)
		if chosen_spawns.size() >= (16 if level_index == 0 else 19): break
	for dpos in chosen_spawns:
		if level_index == 0:
			enemies.append({"pos":dpos,"hp":20,"max_hp":20,"speed":82.0,"boss":false,"type":"drone","alive":true,"phase":spawn_rng.randf_range(0.0,TAU),"shot_timer":spawn_rng.randf_range(0.7,1.8),"path_timer":spawn_rng.randf_range(0.1,0.8),"path":[],"path_index":0})
		else:
			var sentinel_type := "sentinel" if randi_range(0,2) != 0 else "striker"
			enemies.append({"pos":dpos,"hp":(35 if sentinel_type == "sentinel" else 25),"max_hp":(35 if sentinel_type == "sentinel" else 25),"speed":(72.0 if sentinel_type == "sentinel" else 112.0),"boss":false,"type":sentinel_type,"alive":true,"phase":spawn_rng.randf_range(0.0,TAU),"shot_timer":spawn_rng.randf_range(0.8,1.8),"path_timer":spawn_rng.randf_range(0.1,0.8),"path":[],"path_index":0})
	if level_index == 0:
		enemies.append({"pos":Vector2.ZERO,"hp":250,"max_hp":250,"speed":68.0,"boss":true,"type":"spider_mech","alive":false,"phase":0.0,"shot_timer":0.8,"special_timer":2.0,"path_timer":0.0,"path":[],"path_index":0})
	else:
		enemies.append({"pos":Vector2.ZERO,"hp":500,"max_hp":500,"speed":83.0,"boss":true,"type":"chaos_overlord","alive":false,"phase":0.0,"shot_timer":0.65,"special_timer":1.8,"path_timer":0.0,"path":[],"path_index":0})
	_update_exploration()
	if level_index == 0:
		_set_message("THE AWAKENING — CLEAR THE DRONES. THE SPIDER-MECH WAITS IN THE CORRUPTED SIGNAL.", 5.0)
	else:
		_set_message("LEVEL 2 // THE NULL FOUNDRY — SENTINELS ACTIVE. FIND THE CHAOS OVERLORD.", 5.0)

func _update_player(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direction.y += 1
	player_moving = direction.length_squared() > 0.0
	if player_moving:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			audio_manager.call("play_sfx", "footstep", -8.0)
			footstep_timer = 0.31
		direction = direction.normalized()
		player_facing = direction
		var next_pos := player_pos + direction * PLAYER_SPEED * delta
		if not _blocked(next_pos):
			player_pos = next_pos
		else:
			var x_only := Vector2(player_pos.x + direction.x * PLAYER_SPEED * delta, player_pos.y)
			var y_only := Vector2(player_pos.x, player_pos.y + direction.y * PLAYER_SPEED * delta)
			if not _blocked(x_only): player_pos.x = x_only.x
			if not _blocked(y_only): player_pos.y = y_only.y
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_key_pressed(KEY_SHIFT):
		_fire_pulse()

func _try_dash() -> void:
	if dash_cooldown > 0.0:
		return
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direction.y += 1.0
	if direction == Vector2.ZERO:
		direction = player_facing
	audio_manager.call("play_sfx", "dash", -2.0)
	direction = direction.normalized()
	var destination := player_pos + direction * 145.0
	var steps := 12
	for i in range(1, steps + 1):
		var candidate: Vector2 = player_pos.lerp(destination, float(i) / float(steps))
		if _blocked(candidate):
			break
		player_pos = candidate
	dash_cooldown = 0.9
	_spawn_burst(player_pos, Color(0.15,0.9,1.0), 12)
	_set_message("PHASE DASH", 0.6)

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return screen_pos - SCREEN * 0.5 + camera_pos

func _segment_hits_obstacle(start_pos: Vector2, end_pos: Vector2) -> bool:
	var distance := start_pos.distance_to(end_pos)
	var steps := maxi(1, int(ceil(distance / 8.0)))
	for i in range(1, steps + 1):
		var point: Vector2 = start_pos.lerp(end_pos, float(i) / float(steps))
		for obstacle in obstacles:
			if obstacle.has_point(point):
				return true
		for prop_rect in prop_collision_rects:
			if prop_rect.has_point(point):
				return true
	return false

func _blocked(p: Vector2) -> bool:
	if p.x < 35 or p.x > WORLD_SIZE.x - 35 or p.y < 35 or p.y > WORLD_SIZE.y - 35:
		return true
	var tile_center := Vector2(floor(p.x / TILE) * TILE + TILE * 0.5, floor(p.y / TILE) * TILE + TILE * 0.5)
	if _terrain_index(int(tile_center.x), int(tile_center.y)) == 3:
		return true
	for r in obstacles:
		if r.grow(13).has_point(p): return true
	for r in prop_collision_rects:
		if r.grow(7).has_point(p): return true
	return false

func _rebuild_navigation_cache() -> void:
	navigation_blocked_cells.clear()
	for cy in range(WORLD_CELLS.y):
		for cx in range(WORLD_CELLS.x):
			var cell := Vector2i(cx, cy)
			var center := Vector2(cx * TILE + TILE * 0.5, cy * TILE + TILE * 0.5)
			if _blocked(center):
				navigation_blocked_cells[cell] = true

func _path_cell_blocked(cell: Vector2i) -> bool:
	return navigation_blocked_cells.has(cell)

func _find_path(start_pos: Vector2, goal_pos: Vector2) -> Array[Vector2]:
	# Breadth-first grid routing lets enemies move around obstacles rather than pushing into them.
	var start_cell := Vector2i(clampi(int(start_pos.x / TILE), 0, int(WORLD_CELLS.x)-1), clampi(int(start_pos.y / TILE), 0, int(WORLD_CELLS.y)-1))
	var goal_cell := Vector2i(clampi(int(goal_pos.x / TILE), 0, int(WORLD_CELLS.x)-1), clampi(int(goal_pos.y / TILE), 0, int(WORLD_CELLS.y)-1))
	# The player's exact tile can overlap a blocked tile when standing close to a prop edge.
	# Route to the nearest walkable cell instead of sending an enemy into the prop and freezing it.
	if _path_cell_blocked(goal_cell):
		var nearest_goal := goal_cell
		var nearest_distance := INF
		for radius in range(1, 5):
			for oy in range(-radius, radius + 1):
				for ox in range(-radius, radius + 1):
					if maxi(abs(ox), abs(oy)) != radius:
						continue
					var candidate_goal := goal_cell + Vector2i(ox, oy)
					if candidate_goal.x < 1 or candidate_goal.y < 1 or candidate_goal.x >= WORLD_CELLS.x - 1 or candidate_goal.y >= WORLD_CELLS.y - 1:
						continue
					if _path_cell_blocked(candidate_goal):
						continue
					var candidate_distance := Vector2(candidate_goal.x * TILE + TILE * 0.5, candidate_goal.y * TILE + TILE * 0.5).distance_to(goal_pos)
					if candidate_distance < nearest_distance:
						nearest_distance = candidate_distance
						nearest_goal = candidate_goal
			if nearest_distance < INF:
				break
		if nearest_distance == INF:
			return []
		goal_cell = nearest_goal
	if start_cell == goal_cell: return []
	var queue: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {start_cell: start_cell}
	var head := 0
	var found := false
	var dirs: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	while head < queue.size() and head < 4500:
		var current: Vector2i = queue[head]; head += 1
		if current == goal_cell: found = true; break
		for step in dirs:
			var nxt: Vector2i = current + step
			if nxt.x < 1 or nxt.y < 1 or nxt.x >= WORLD_CELLS.x-1 or nxt.y >= WORLD_CELLS.y-1 or came_from.has(nxt): continue
			var center := Vector2(nxt.x * TILE + TILE*0.5, nxt.y * TILE + TILE*0.5)
			if nxt != goal_cell and _path_cell_blocked(nxt): continue
			came_from[nxt] = current; queue.append(nxt)
	if not found: return []
	var result: Array[Vector2] = []
	var cursor: Vector2i = goal_cell
	while cursor != start_cell:
		result.append(Vector2(cursor.x*TILE+TILE*0.5,cursor.y*TILE+TILE*0.5))
		cursor = came_from[cursor]
		if result.size() > 200: break
	result.reverse()
	return result

func _update_combat(delta: float) -> void:
	# Advance all projectiles and resolve collisions by team.
	for i in range(projectiles.size() - 1, -1, -1):
		var p: Dictionary = projectiles[i]
		var old_pos: Vector2 = p["pos"]
		var next_projectile_pos: Vector2 = old_pos + p["vel"] * delta
		p["life"] = float(p["life"]) - delta
		var remove: bool = float(p["life"]) <= 0.0 or next_projectile_pos.x < 0.0 or next_projectile_pos.x > WORLD_SIZE.x or next_projectile_pos.y < 0.0 or next_projectile_pos.y > WORLD_SIZE.y
		if not remove and _segment_hits_obstacle(old_pos, next_projectile_pos):
			_spawn_burst(old_pos.lerp(next_projectile_pos, 0.5), p["color"], 5)
			remove = true
		else:
			p["pos"] = next_projectile_pos
		if not remove and p.get("team", "player") == "player":
			for enemy in enemies:
				if enemy["alive"] and p["pos"].distance_to(enemy["pos"]) < (50.0 if enemy["boss"] else 34.0):
					enemy["hp"] -= int(p["damage"])
					audio_manager.call("play_sfx", "boss_hit" if enemy["boss"] else "drone_hit", -5.0)
					_spawn_burst(enemy["pos"], Color(1.0, 0.25, 0.38), 8)
					effects.append({"pos":p["pos"], "life":0.12, "max_life":0.12, "color":p["color"], "radius":15.0})
					remove = true
					if enemy["hp"] <= 0:
						enemy["alive"] = false
						audio_manager.call("play_sfx", "boss_death" if enemy["boss"] else "drone_death", -1.0)
						if enemy["boss"]:
							audio_manager.call("stop_music")
						data_fragments += 12 if enemy["boss"] else 4
						_spawn_burst(enemy["pos"], Color(0.15, 0.9, 1.0), 22)
					break
		elif not remove and p.get("team", "player") == "enemy":
			if p["pos"].distance_to(player_pos) < 24.0 and invulnerability <= 0.0:
				player_hp -= int(p["damage"])
				invulnerability = 0.55
				audio_manager.call("play_sfx", "player_hit", -2.0)
				_spawn_burst(player_pos, Color(1.0, 0.15, 0.25), 12)
				remove = true
				if player_hp <= 0:
					player_hp = 0
					game_state = "game_over"
					audio_manager.call("play_sfx", "game_over", 0.0)
					_set_message("SIGNAL LOST", 5.0)
		if remove:
			projectiles.remove_at(i)

	_check_boss_spawn()
	# Enemy navigation uses cached grid paths and line-of-sight checks.
	for enemy in enemies:
		if not enemy["alive"]: continue
		enemy["phase"] += delta * (1.6 if not enemy["boss"] else 0.75)
		enemy["shot_timer"] = float(enemy.get("shot_timer",1.0)) - delta
		var to_player: Vector2 = player_pos - enemy["pos"]
		var distance := to_player.length()
		var preferred_range := (125.0 if enemy.get("type", "") == "striker" else 185.0) if not enemy["boss"] else (210.0 if level_index == 1 else 245.0)
		if distance > preferred_range and distance > 1.0:
			enemy["path_timer"] = float(enemy.get("path_timer",0.0)) - delta
			var path: Array = enemy.get("path",[])
			var path_index := int(enemy.get("path_index",0))
			if float(enemy["path_timer"]) <= 0.0 or path_index >= path.size():
				path = _find_path(enemy["pos"],player_pos)
				enemy["path"] = path; enemy["path_index"] = 0
				enemy["path_timer"] = 0.62 if not enemy["boss"] else 0.72
				path_index = 0
			if path_index < path.size():
				var waypoint: Vector2 = path[path_index]
				var delta_waypoint: Vector2 = waypoint - enemy["pos"]
				if delta_waypoint.length() < 14.0:
					enemy["path_index"] = path_index + 1
				else:
					var candidate: Vector2 = enemy["pos"] + delta_waypoint.normalized() * float(enemy["speed"]) * delta
					if not _blocked(candidate): enemy["pos"] = candidate
					else: enemy["path_timer"] = 0.0
		if distance < (560.0 if enemy["boss"] else 460.0) and distance > 1.0 and float(enemy["shot_timer"]) <= 0.0:
			var shot_dir: Vector2 = to_player.normalized()
			if not enemy["boss"] and _segment_hits_obstacle(enemy["pos"],player_pos):
				enemy["shot_timer"] = 0.45
				continue
			var shot_speed := (310.0 if level_index == 1 else 260.0) if not enemy["boss"] else (390.0 if level_index == 1 else 350.0)
			var shot_damage: int
			if enemy["boss"]:
				shot_damage = 20 if level_index == 1 else 15
			else:
				shot_damage = (15 if enemy.get("type", "") == "striker" else 10) if level_index == 1 else 5
			var shot_color := Color("#ff4f8f") if level_index == 1 else Color(1.0,0.12,0.28)
			projectiles.append({"pos":enemy["pos"]+shot_dir*25.0,"vel":shot_dir*shot_speed,"life":2.1,"damage":shot_damage,"color":(Color("#ff174d") if level_index == 1 else Color(1.0,0.05,0.55)) if enemy["boss"] else shot_color,"team":"enemy"})
			audio_manager.call("play_sfx", "boss_fire" if enemy["boss"] else "drone_fire", -5.0)
			_spawn_burst(enemy["pos"]+shot_dir*22.0,Color(1.0,0.1,0.25),5)
			enemy["shot_timer"] = randf_range(1.2,1.8) if not enemy["boss"] else randf_range(0.65,1.0)
		if enemy["boss"]:
			enemy["special_timer"] = float(enemy.get("special_timer",2.0)) - delta
			if float(enemy["special_timer"]) <= 0.0:
				audio_manager.call("play_sfx", "boss_fire", -3.0)
				_spawn_burst(enemy["pos"],Color(1.0,0.02,0.18),32)
				for shot_i in range(16 if level_index == 1 else 12):
					var radial_dir := Vector2.RIGHT.rotated(TAU*float(shot_i)/(16.0 if level_index == 1 else 12.0)+float(enemy["phase"])*0.35)
					projectiles.append({"pos":enemy["pos"]+radial_dir*38.0,"vel":radial_dir*(240.0 if level_index == 1 else 205.0),"life":2.6,"damage":(15 if level_index == 1 else 10),"color":Color("#ff1768") if level_index == 1 else Color(1.0,0.03,0.24),"team":"enemy"})
				var aimed_dir: Vector2 = (player_pos-enemy["pos"]).normalized()
				for spread in [-0.22,0.0,0.22]:
					var burst_dir: Vector2 = aimed_dir.rotated(spread)
					projectiles.append({"pos":enemy["pos"]+burst_dir*42.0,"vel":burst_dir*390.0,"life":2.0,"damage":(25 if level_index == 1 else 20),"color":Color(1.0,0.2,0.58),"team":"enemy"})
				enemy["special_timer"] = 3.0 if level_index == 1 else 3.8
				# Chaos Overlord calls reinforcements: capped so the arena remains fair and readable.
				if level_index == 1:
					var active_summons := 0
					for unit in enemies:
						if not unit["boss"] and unit["alive"]:
							active_summons += 1
					if active_summons < 5:
						for summon_i in range(2):
							var spawn_angle: float = randf() * TAU
							var spawn_pos: Vector2 = enemy["pos"] + Vector2.RIGHT.rotated(spawn_angle) * randf_range(100.0, 145.0)
							if not _blocked(spawn_pos):
								enemies.append({"pos":spawn_pos,"hp":30,"max_hp":30,"speed":88.0,"boss":false,"type":"sentinel","alive":true,"phase":randf_range(0.0,TAU),"shot_timer":randf_range(0.8,1.4),"path_timer":0.1,"path":[],"path_index":0})
						audio_manager.call("play_sfx", "boss_stinger", -3.0)
						_set_message("CHAOS OVERLORD // REINFORCEMENTS DEPLOYED", 2.4)
		if distance < (72.0 if enemy["boss"] else (30.0 if enemy.get("type", "") == "striker" else 36.0)) and invulnerability <= 0.0:
			var contact_damage: int
			if enemy["boss"]:
				contact_damage = 25 if level_index == 1 else 20
			elif level_index == 1:
				contact_damage = 15 if enemy.get("type", "") == "striker" else 10
			else:
				contact_damage = 10
			player_hp -= contact_damage
			invulnerability = 0.65
			audio_manager.call("play_sfx", "player_hit", -2.0)
			_spawn_burst(player_pos,Color(1.0,0.15,0.25),12)
			if player_hp <= 0:
				player_hp = 0; game_state = "game_over"; audio_manager.call("play_sfx", "game_over", 0.0); _set_message("SIGNAL LOST",5.0)

	# Expire visual effects.
	for i in range(effects.size() - 1, -1, -1):
		effects[i]["life"] -= delta
		if effects[i]["life"] <= 0:
			effects.remove_at(i)

func _check_boss_spawn() -> void:
	if boss_spawned:
		return
	var living_drones := 0
	for enemy in enemies:
		if not enemy["boss"] and enemy["alive"]:
			living_drones += 1
	if living_drones == 0:
		for enemy in enemies:
			if enemy["boss"]:
				enemy["alive"] = true
				enemy["hp"] = enemy["max_hp"]
				# Spawn in a clear arena region away from walls and the player; never inside a relay slab.
				var boss_candidates: Array[Vector2] = []
				for by in range(4, WORLD_CELLS.y - 4, 2):
					for bx in range(4, WORLD_CELLS.x - 4, 2):
						var bp := Vector2(bx * TILE + TILE * 0.5, by * TILE + TILE * 0.5)
						var d := bp.distance_to(player_pos)
						if d >= 360.0 and d <= 680.0 and not _blocked(bp):
							boss_candidates.append(bp)
				if boss_candidates.is_empty():
					enemy["pos"] = Vector2(2050, 480)
				else:
					enemy["pos"] = boss_candidates[randi_range(0, boss_candidates.size() - 1)]
				enemy["path"] = []
				enemy["path_index"] = 0
				enemy["path_timer"] = 0.0
				enemy["shot_timer"] = 0.7
				boss_spawned = true
				boss_intro_timer = 2.6
				audio_manager.call("play_sfx", "boss_stinger", 2.0 if level_index == 1 else 1.0)
				audio_manager.call("stop_music")
				_spawn_burst(enemy["pos"],Color(1.0,0.02,0.12),80)
				_set_message(("WARNING // NULL FOUNDRY OVERLORD ONLINE" if level_index == 1 else "CRITICAL FAILURE // WORLD CORRUPTION // SPIDER-MECH ONLINE"),5.0)
				break

func _update_pickups() -> void:
	for item in pickups:
		if item["taken"]:
			continue
		if player_pos.distance_to(item["pos"]) < 30:
			if item["kind"] == "medkit" and player_hp >= player_max_hp:
				continue
			item["taken"] = true
			if item["kind"] == "weapon":
				var w: String = item["weapon"]
				if not owned_weapons.has(w):
					owned_weapons.append(w)
				selected_weapon = w
				audio_manager.call("play_sfx", "weapon_collect", 0.0)
				_set_message("WEAPON ACQUIRED: %s" % w.to_upper(), 3.0)
				_spawn_burst(item["pos"], Color(0.1,0.95,1.0), 20)
			elif item["kind"] == "medkit":
				var old_hp: int = player_hp
				player_hp = mini(player_max_hp, player_hp + 20)
				var healed: int = player_hp - old_hp
				audio_manager.call("play_sfx", "shard_collect", -1.0)
				_set_message("MEDKIT // +%d HEALTH" % healed, 2.0)
				_spawn_burst(item["pos"], Color("#63ff9b"), 20)
			else:
				audio_manager.call("play_sfx", "shard_collect", -2.0)
				data_fragments += 10
				_set_message("+10 DATA FRAGMENTS", 1.8)
				_spawn_burst(item["pos"], Color(0.9,0.2,1.0), 12)

func _boss_is_defeated() -> bool:
	if not boss_spawned:
		return false
	for enemy in enemies:
		if enemy["boss"]:
			return not enemy["alive"]
	return false

func _check_level_exit() -> void:
	# The extraction gate appears only after the active level's boss is defeated.
	if not _boss_is_defeated():
		return
	if player_pos.distance_to(exit_pos) < 58.0:
		if level_index == 0:
			# Portal progression: no level-clear menu and no new run. Keep the arsenal and shards.
			audio_manager.call("play_sfx", "gate_open", 0.0)
			player_max_hp = 200
			player_hp = player_max_hp
			checkpoint_level = 1
			upgrade_menu_open = false
			_load_level(1)
			game_state = "playing"
			audio_manager.call("stop_music")
			_set_message("PORTAL TRANSIT // NULL FOUNDRY REACHED // MAX HEALTH 200 // CHECKPOINT SAVED", 6.0)
		else:
			game_state = "victory"
			audio_manager.call("play_sfx", "gate_open", 0.0)
			get_tree().create_timer(0.42).timeout.connect(func(): audio_manager.call("play_sfx", "victory", -2.0))
			_set_message("NULL FOUNDRY CLEARED — THE ENGINE CORE IS EXPOSED.", 5.0)

func _interact() -> void:
	if player_pos.distance_to(terminal_pos) < 100.0:
		upgrade_menu_open = true
		audio_manager.call("play_sfx", "menu_select", -6.0)
	else:
		_set_message("APPROACH THE UPGRADE TERMINAL TO OPEN THE WEAPON WORKBENCH.", 2.2)

func _purchase_weapon_upgrade() -> void:
	if selected_weapon == "" or not owned_weapons.has(selected_weapon):
		_set_message("NO WEAPON EQUIPPED — COLLECT A WEAPON FIRST.", 2.0)
		return
	var current_level: int = int(weapon_levels.get(selected_weapon, 1))
	if current_level >= 3:
		_set_message("WEAPON AT MAX LEVEL 03.", 2.0)
		return
	var cost: int = 20 * current_level
	if data_fragments < cost:
		_set_message("INSUFFICIENT SHARDS // NEED %d, HAVE %d" % [cost, data_fragments], 2.5)
		return
	data_fragments -= cost
	weapon_levels[selected_weapon] = current_level + 1
	audio_manager.call("play_sfx", "upgrade", -2.0)
	_spawn_burst(terminal_pos, Color(0.15,0.95,1.0), 28)
	_set_message("%s UPGRADED // LEVEL %02d" % [selected_weapon.to_upper(), current_level + 1], 2.4)

func _cycle_weapon() -> void:
	if owned_weapons.is_empty():
		_set_message("NO WEAPONS FOUND", 1.3)
		return
	var index: int = owned_weapons.find(selected_weapon)
	index = posmod(index + 1, owned_weapons.size())
	_select_weapon(index)

func _retry_checkpoint() -> void:
	_load_level(1)
	player_hp = player_max_hp
	game_state = "playing"
	upgrade_menu_open = false
	audio_manager.call("stop_music")
	_set_message("CHECKPOINT RESTORED // NULL FOUNDRY // HEALTH REPLENISHED", 4.0)

func _select_weapon(index: int) -> void:
	var available := ["Pulse Gun", "Laser Blade", "Rail Blaster", "Nova Core"]
	if index < owned_weapons.size():
		selected_weapon = owned_weapons[index]
		audio_manager.call("play_sfx", "menu_select", -8.0)
		_set_message("EQUIPPED: %s" % selected_weapon.to_upper(), 1.3)
	else:
		_set_message("WEAPON SLOT EMPTY — COLLECT MORE WEAPONS", 1.2)

func _fire_pulse() -> void:
	if selected_weapon == "" or not owned_weapons.has(selected_weapon):
		return
	if selected_weapon == "Laser Blade":
		_fire_blade()
		return
	if selected_weapon == "Nova Core":
		_fire_nova()
		return
	if fire_cooldown > 0: return
	var direction := (aim_pos - player_pos).normalized()
	if direction == Vector2.ZERO: direction = Vector2.RIGHT
	player_facing = direction
	var damage: int = 3 * int(weapon_levels.get(selected_weapon, 1))
	var speed := 590.0
	var cooldown := 0.17
	if selected_weapon == "Rail Blaster":
		damage = 5 * int(weapon_levels.get(selected_weapon, 1))
		speed = 900.0
		cooldown = 0.65
		if int(weapon_levels.get(selected_weapon, 1)) >= 3:
			# The piercing behavior is handled by marking the projectile.
			pass
	if selected_weapon == "Pulse Gun" and int(weapon_levels.get(selected_weapon, 1)) >= 3:
		for offset in [-0.16, 0.0, 0.16]:
			var dir := direction.rotated(offset)
			projectiles.append({"pos":player_pos + dir * 22, "vel":dir * speed, "life":0.85, "damage":damage, "color":Color(0.15,0.9,1.0), "team":"player"})
	else:
		projectiles.append({"pos":player_pos + direction * 22, "vel":direction * speed, "life":0.85, "damage":damage, "color":Color(0.15,0.9,1.0) if selected_weapon == "Pulse Gun" else Color(1.0,0.25,0.45), "team":"player"})
	audio_manager.call("play_sfx", "pulse_fire" if selected_weapon == "Pulse Gun" else "rail_fire", -3.0)
	fire_cooldown = cooldown

func _fire_rail() -> void:
	if not owned_weapons.has("Rail Blaster"):
		_set_message("RAIL BLASTER NOT ACQUIRED", 1.5)
		return
	if fire_cooldown > 0.0:
		return
	selected_weapon = "Rail Blaster"
	fire_cooldown = 0.62
	var direction := (aim_pos - player_pos).normalized()
	if direction == Vector2.ZERO: direction = player_facing
	var beam_end := player_pos + direction * 760.0
	var steps := 100
	for i in range(1, steps + 1):
		var point: Vector2 = player_pos.lerp(beam_end, float(i) / float(steps))
		var hit_wall := false
		for obstacle in obstacles:
			if obstacle.has_point(point):
				beam_end = point
				hit_wall = true
				break
		if not hit_wall:
			for prop_rect in prop_collision_rects:
				if prop_rect.has_point(point):
					beam_end = point
					hit_wall = true
					break
		if hit_wall: break
	for enemy in enemies:
		if enemy["alive"]:
			var to_enemy: Vector2 = enemy["pos"] - player_pos
			var along := to_enemy.dot(direction)
			var perpendicular := absf(to_enemy.cross(direction))
			if along > 0 and along < player_pos.distance_to(beam_end) and perpendicular < (42.0 if enemy["boss"] else 27.0):
				enemy["hp"] -= 6 * int(weapon_levels.get("Rail Blaster",1))
				_spawn_burst(enemy["pos"], Color(0.3,0.95,1.0), 12)
				if enemy["hp"] <= 0:
					enemy["alive"] = false
					audio_manager.call("play_sfx", "boss_death" if enemy["boss"] else "drone_death", -1.0)
					if enemy["boss"]: audio_manager.call("stop_music")
					data_fragments += 12 if enemy["boss"] else 4
					_spawn_burst(enemy["pos"], Color(0.1,0.95,1.0), 24)
	audio_manager.call("play_sfx", "rail_fire", -1.0)
	effects.append({"pos":player_pos, "end":beam_end, "life":0.20, "max_life":0.20, "color":Color(0.25,0.95,1.0), "radius":5.0})
	_check_boss_spawn()


func _fire_blade() -> void:
	if blade_cooldown > 0: return
	blade_cooldown = 0.42
	var direction := (aim_pos - player_pos).normalized()
	var center := player_pos + direction * 40
	var radius := 72.0 + 12.0 * int(weapon_levels.get("Laser Blade",1))
	for enemy in enemies:
		if enemy["alive"] and enemy["pos"].distance_to(center) < radius and not _segment_hits_obstacle(player_pos, enemy["pos"]):
			enemy["hp"] -= 4 * int(weapon_levels.get("Laser Blade",1))
			if enemy["hp"] <= 0:
				enemy["alive"] = false
				audio_manager.call("play_sfx", "boss_death" if enemy["boss"] else "drone_death", -1.0)
				if enemy["boss"]: audio_manager.call("stop_music")
				data_fragments += 4
			_spawn_burst(enemy["pos"], Color(0.1,0.95,1.0), 12)
	audio_manager.call("play_sfx", "blade_swing", -2.0)
	effects.append({"pos":center, "life":0.22, "max_life":0.22, "color":Color(0.1,0.95,1.0), "radius":radius})
	_check_boss_spawn()

func _fire_nova() -> void:
	if not owned_weapons.has("Nova Core"):
		_set_message("NOVA CORE NOT ACQUIRED", 1.5)
		return
	if nova_cooldown > 0: return
	nova_cooldown = 3.0
	var radius := 185.0 + 30.0 * int(weapon_levels.get("Nova Core",1))
	for enemy in enemies:
		if enemy["alive"] and enemy["pos"].distance_to(player_pos) <= radius:
			enemy["hp"] -= 10 * int(weapon_levels.get("Nova Core",1))
			if enemy["hp"] <= 0:
				enemy["alive"] = false
				audio_manager.call("play_sfx", "boss_death" if enemy["boss"] else "drone_death", -1.0)
				if enemy["boss"]: audio_manager.call("stop_music")
				data_fragments += 4 if not enemy["boss"] else 12
	audio_manager.call("play_sfx", "nova_blast", 0.0)
	_spawn_burst(player_pos, Color(0.1,0.95,1.0), 42)
	effects.append({"pos":player_pos, "life":0.55, "max_life":0.55, "color":Color(0.1,0.95,1.0), "radius":radius})
	_check_boss_spawn()
	_set_message("NOVA BURST", 1.0)

func _spawn_burst(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		var angle := randf() * TAU
		var speed := randf_range(35.0, 190.0)
		effects.append({"pos":pos, "vel":Vector2.RIGHT.rotated(angle)*speed, "life":randf_range(0.18,0.55), "max_life":0.55, "color":color, "radius":randf_range(2.0,5.0)})

func _set_message(text: String, seconds: float = 2.0) -> void:
	message = text
	message_time = seconds

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("#090610" if level_index == 1 else "#070b14"))
	if game_state == "title":
		_draw_title()
		return
	if game_state == "story_intro":
		_draw_story_intro()
		return
	if game_state == "settings":
		_draw_settings()
		return
	if game_state == "credits":
		_draw_credits()
		return
	_draw_world()
	if game_state == "paused":
		_draw_overlay("PAUSED", "Press ESC to continue")
	elif game_state == "game_over":
		_draw_overlay("SIGNAL LOST", ("Checkpoint available // retry at the Null Foundry." if checkpoint_level == 1 else "The factory consumed your signal."))
	elif game_state == "victory":
		_draw_overlay(("LEVEL 1 CLEARED" if level_index == 0 else "LEVEL 2 CLEARED"), ("The Spider-Mech is down. Continue into the Null Foundry." if level_index == 0 else "The Chaos Overlord is down. The Engine Core is exposed."))
	if show_algorithm_demo:
		_draw_algorithm_panel()

func _draw_world() -> void:
	# Camera transform: draw a real 72x51-tile world while keeping the HUD screen-fixed.
	draw_set_transform(SCREEN * 0.5 - camera_pos, 0.0, Vector2.ONE)
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#160e22" if level_index == 1 else "#0b1b28"))
	var visible_left := maxi(0, int((camera_pos.x - SCREEN.x * 0.5) / 32.0) * 32 - 32)
	var visible_right := mini(int(WORLD_SIZE.x), int((camera_pos.x + SCREEN.x * 0.5) / 32.0) * 32 + 64)
	var visible_top := maxi(0, int((camera_pos.y - SCREEN.y * 0.5) / 32.0) * 32 - 32)
	var visible_bottom := mini(int(WORLD_SIZE.y), int((camera_pos.y + SCREEN.y * 0.5) / 32.0) * 32 + 64)
	for y in range(visible_top, visible_bottom, 32):
		for x in range(visible_left, visible_right, 32):
			var tile_index := _terrain_index(x, y)
			if floor_textures.size() > 0:
				draw_texture_rect(floor_textures[tile_index], Rect2(x,y,32,32), false, (Color("#c7a7ff") if tile_index == 2 else (Color("#7db5d6") if tile_index == 3 else Color("#b0c4d8"))) if level_index == 1 else Color.WHITE)
			else:
				draw_rect(Rect2(x,y,32,32), Color("#0b1421"))
	# Biome details: ruins, foliage silhouettes, water pools and path markings, not a micro-grid.
	_draw_terrain_props()
	_draw_landmarks()
	draw_rect(Rect2(0,0,WORLD_SIZE.x,12), Color("#152f40"))
	draw_rect(Rect2(0,WORLD_SIZE.y-12,WORLD_SIZE.x,12), Color("#152f40"))
	draw_rect(Rect2(0,0,12,WORLD_SIZE.y), Color("#152f40"))
	draw_rect(Rect2(WORLD_SIZE.x-12,0,12,WORLD_SIZE.y), Color("#152f40"))
	# Ambient pools of light behind machinery and the extraction gate.
	for glow_i in range(10):
		var glow_pos := Vector2(180 + glow_i * 220, 420 + sin(elapsed * 0.35 + glow_i) * 130)
		draw_circle(glow_pos, 145, Color(0.02,0.34,0.46,0.045))
	# Ancient relay ruins: layered silhouettes, chipped crowns, circuit seams and small warning lights.
	# Each structure reads as architecture with a function, not a plain storage box.
	for obstacle_i in range(obstacles.size()):
		var r: Rect2 = obstacles[obstacle_i]
		draw_rect(Rect2(r.position + Vector2(8,10), r.size + Vector2(2,2)), Color(0.0,0.0,0.0,0.42))
		var shell := PackedVector2Array([
			r.position + Vector2(4,0), r.position + Vector2(r.size.x-7,0),
			r.position + Vector2(r.size.x,8), r.position + Vector2(r.size.x,r.size.y-4),
			r.position + Vector2(r.size.x-6,r.size.y), r.position + Vector2(0,r.size.y-5),
			r.position + Vector2(0,7)
		])
		draw_colored_polygon(shell, Color("#152638"))
		var inset := PackedVector2Array([
			r.position + Vector2(9, 9), r.position + Vector2(r.size.x - 15, 9),
			r.position + Vector2(r.size.x - 10, 18), r.position + Vector2(r.size.x - 15, r.size.y - 16),
			r.position + Vector2(r.size.x * 0.58, r.size.y - 10), r.position + Vector2(9, r.size.y - 17)
		])
		draw_colored_polygon(inset, Color("#1c3547"))
		# Offset energy conduit and broken side buttress make each relic read as a pylon, not a crate.
		draw_colored_polygon(PackedVector2Array([r.position + Vector2(2, 14), r.position + Vector2(8, 8), r.position + Vector2(8, r.size.y - 10), r.position + Vector2(2, r.size.y - 4)]), Color("#0d1b2b"))
		draw_rect(Rect2(r.position+Vector2(12,13),Vector2(maxf(8.0,r.size.x-24),3)),Color("#287b8c"))
		draw_rect(Rect2(r.position+Vector2(12,23),Vector2(3, maxf(7.0,r.size.y-36))),Color("#0b1727"))
		# Broken neon seams and status pixels make the old infrastructure feel corrupted.
		draw_line(r.position+Vector2(10,r.size.y-16),r.position+Vector2(r.size.x*0.48,r.size.y-16),Color("#45eaff"),2.0)
		draw_line(r.position+Vector2(r.size.x*0.68,10),r.position+Vector2(r.size.x-10,10),Color("#b64bff"),1.0)
		for stripe_i in range(3):
			draw_rect(Rect2(r.position+Vector2(10+stripe_i*7,5),Vector2(3,3)),Color("#ff456f" if obstacle_i % 3 == 0 else "#5af3ed"))
		if obstacle_i in [2, 5, 10, 15]:
			draw_string(ThemeDB.fallback_font,r.position+Vector2(8,r.size.y*0.58),"RELAY // %02d" % (obstacle_i+1),HORIZONTAL_ALIGNMENT_LEFT,minf(r.size.x-12,130),9,Color("#8ab8c8"))
		# A few structures have a broken antenna / power conduit silhouette.
		if obstacle_i % 4 == 1:
			draw_line(r.position+Vector2(r.size.x-14,4),r.position+Vector2(r.size.x-14,-15),Color("#3f8799"),2.0)
			draw_circle(r.position+Vector2(r.size.x-14,-17),3.0,Color("#ff3d76"))
	# Scattered cyan beacons mark routes and points of interest across the wilderness.
	for beacon in [Vector2(260,260),Vector2(700,940),Vector2(1360,520),Vector2(1900,1200)]:
		draw_circle(beacon, 15.0 + 2.0 * sin(elapsed*2.0), Color(0.05,0.8,1.0,0.07))
		draw_circle(beacon, 4.0, Color("#36dff4"))
	# Upgrade terminal: a small interactive node embedded in the Signal Shrine.
	draw_colored_polygon(PackedVector2Array([terminal_pos+Vector2(-28,0),terminal_pos+Vector2(-17,-23),terminal_pos+Vector2(17,-23),terminal_pos+Vector2(28,0),terminal_pos+Vector2(17,23),terminal_pos+Vector2(-17,23)]),Color("#112b40"))
	draw_colored_polygon(PackedVector2Array([terminal_pos+Vector2(-19,0),terminal_pos+Vector2(-11,-15),terminal_pos+Vector2(11,-15),terminal_pos+Vector2(19,0),terminal_pos+Vector2(11,15),terminal_pos+Vector2(-11,15)]),Color("#0a7588"))
	draw_arc(terminal_pos,31,elapsed*0.9,elapsed*0.9+PI*1.45,28,Color("#53f5ff",0.8),2.0)
	draw_circle(terminal_pos, 9 + 2*sin(elapsed*3), Color(0.1,0.95,1.0,0.8), false, 2.0)
	draw_diamond(terminal_pos,5,Color.WHITE)
	_draw_gate()
	# Weapon pickups are actual recognizable pixel sprites, lifted above the ground in a strong beacon.
	for item in pickups:
		if item["taken"]: continue
		var pos: Vector2 = item["pos"]
		if item["kind"] == "weapon":
			var weapon_name: String = item["weapon"]
			var pulse := 0.5 + 0.5 * sin(elapsed * 4.0 + pos.x * 0.01)
			var glow_color := Color("#ff4d91") if weapon_name == "Rail Blaster" else (Color("#c45bff") if weapon_name == "Nova Core" else Color("#4cf5ff"))
			draw_custom_ellipse(pos+Vector2(0,15),Vector2(27,9),Color(glow_color.r,glow_color.g,glow_color.b,0.16))
			draw_circle(pos, 31.0 + pulse*5.0, Color(glow_color.r,glow_color.g,glow_color.b,0.045+pulse*0.035))
			draw_arc(pos, 25.0 + pulse*3.0, elapsed*0.8, elapsed*0.8+PI*1.45, 28, Color(glow_color.r,glow_color.g,glow_color.b,0.78), 2.0)
			draw_line(pos+Vector2(0,-37),pos+Vector2(0,-24),Color(glow_color.r,glow_color.g,glow_color.b,0.65),2.0)
			draw_circle(pos+Vector2(0,-39),2.0,Color.WHITE)
			draw_rect(Rect2(pos.x-29,pos.y-21,58,42),Color("#07111d"),false,1.0)
			if weapon_textures.has(weapon_name) and weapon_textures[weapon_name] != null:
				var weapon_tex: Texture2D = weapon_textures[weapon_name]
				draw_texture_rect(weapon_tex,Rect2(pos.x-28,pos.y-18+sin(elapsed*3.2+pos.y*0.01)*2.0,56,38),false)
			draw_string(ThemeDB.fallback_font,pos+Vector2(-62,-48),weapon_name.to_upper(),HORIZONTAL_ALIGNMENT_CENTER,124,10,Color("#e6fdff"))
			draw_string(ThemeDB.fallback_font,pos+Vector2(-62,43),"WEAPON // CLAIM",HORIZONTAL_ALIGNMENT_CENTER,124,8,Color(glow_color.r,glow_color.g,glow_color.b,0.9))
		elif item["kind"] == "medkit":
			var heal_pulse: float = 0.5 + 0.5 * sin(elapsed * 4.5 + pos.y * 0.01)
			draw_circle(pos, 24.0 + heal_pulse * 4.0, Color(0.2, 1.0, 0.48, 0.10 + heal_pulse * 0.04))
			draw_rect(Rect2(pos.x - 15, pos.y - 13, 30, 26), Color("#d9ffe6"))
			draw_rect(Rect2(pos.x - 15, pos.y - 13, 30, 26), Color("#39e879"), false, 2.0)
			draw_rect(Rect2(pos.x - 4, pos.y - 9, 8, 18), Color("#16a84d"))
			draw_rect(Rect2(pos.x - 9, pos.y - 4, 18, 8), Color("#16a84d"))
			draw_string(ThemeDB.fallback_font, pos + Vector2(-46, 30), "MEDKIT // +20 HP", HORIZONTAL_ALIGNMENT_CENTER, 92, 9, Color("#8dffb2"))
		else:
			draw_circle(pos, 17.0 + 3.0*sin(elapsed*4.0),Color(0.84,0.22,1.0,0.10))
			draw_diamond(pos, 9, Color("#d858ff"))
			draw_diamond(pos, 4, Color("#f7d8ff"))
	# enemies
	for enemy in enemies:
		if not enemy["alive"]: continue
		var pos: Vector2 = enemy["pos"]
		if enemy["boss"]:
			var boss_art: Texture2D = chaos_boss_texture if level_index == 1 else boss_texture
			draw_circle(pos, 112 if level_index == 1 else 94, Color(1.0,0.015,0.16,0.11))
			if boss_art:
				var boss_size := Vector2(218,236) if level_index == 1 else Vector2(184,144)
				draw_texture_rect(boss_art, Rect2(pos-boss_size*0.5,boss_size), false, Color.WHITE)
		elif level_index == 1 and sentinel_texture:
			var is_striker: bool = str(enemy.get("type", "sentinel")) == "striker"
			draw_circle(pos, 56 if is_striker else 49, Color(1.0,0.02,0.16,0.10))
			var enemy_size := Vector2(74,90) if is_striker else Vector2(82,96)
			draw_texture_rect(sentinel_texture, Rect2(pos-enemy_size*0.5,enemy_size), false, Color("#ffc4e0") if is_striker else Color.WHITE)
		elif not enemy["boss"] and drone_texture:
			draw_circle(pos, 49, Color(1.0,0.04,0.15,0.08))
			draw_texture_rect(drone_texture, Rect2(pos-Vector2(58,40),Vector2(116,80)), false, Color.WHITE)
		else:
			draw_circle(pos, 22, Color("#351626"))
			draw_circle(pos, 8, Color("#ff3158"))
		var bar_width := 56.0 if enemy["boss"] else 36.0
		draw_rect(Rect2(pos.x-bar_width/2,pos.y-31,bar_width,5), Color("#3b1826"))
		draw_rect(Rect2(pos.x-bar_width/2,pos.y-31,bar_width*clampf(float(enemy["hp"])/float(enemy["max_hp"]),0,1),5), Color("#ff3158"))
	# Layered energy bolts: soft outer bloom, saturated plasma shell, white-hot pixel core.
	for p in projectiles:
		var direction: Vector2 = p["vel"].normalized()
		var length := 25.0 if p.get("team","player") == "player" else 17.0
		var beam_start: Vector2 = p["pos"] - direction * length
		var beam_end: Vector2 = p["pos"] + direction * 5.0
		var c: Color = p["color"]
		draw_line(beam_start,beam_end,Color(c.r,c.g,c.b,0.13),13.0,true)
		draw_line(beam_start,beam_end,Color(c.r,c.g,c.b,0.62),7.0,true)
		draw_line(beam_start,beam_end,Color(0.82,1.0,1.0,0.95),2.0,true)
		draw_circle(p["pos"], 5.0, c)
		draw_circle(p["pos"], 12.0, Color(c.r,c.g,c.b,0.14))
		draw_circle(p["pos"], 2.0, Color.WHITE)
	# effects and weapon rings
	for fx in effects:
		if fx.has("end"):
			var beam_alpha := clampf(float(fx["life"])/float(fx["max_life"]),0.0,1.0)
			var beam_start: Vector2 = fx["pos"]
			var beam_end: Vector2 = fx["end"]
			var beam_dir := (beam_end-beam_start).normalized()
			var beam_normal := Vector2(-beam_dir.y,beam_dir.x)
			var beam_color: Color = fx["color"]
			draw_line(beam_start,beam_end,Color(beam_color.r,beam_color.g,beam_color.b,beam_alpha*0.16),22.0,true)
			draw_line(beam_start,beam_end,Color(beam_color.r,beam_color.g,beam_color.b,beam_alpha*0.58),10.0,true)
			draw_line(beam_start,beam_end,Color(0.78,1.0,1.0,beam_alpha),3.0,true)
			# Jagged ion arcs along the rail beam, with short side branches.
			for arc_i in range(1,13):
				var t0 := float(arc_i-1)/13.0
				var t1 := float(arc_i)/13.0
				var a := beam_start.lerp(beam_end,t0) + beam_normal*sin(elapsed*43.0+arc_i*2.1)*5.0
				var b := beam_start.lerp(beam_end,t1) + beam_normal*cos(elapsed*37.0+arc_i*1.7)*6.0
				draw_line(a,b,Color(0.43,0.96,1.0,beam_alpha*0.9),1.5,true)
				if arc_i % 3 == 0:
					draw_line(b,b+beam_normal*sin(elapsed*29.0+arc_i)*10.0,Color(1.0,0.25,0.72,beam_alpha*0.8),1.0,true)
			draw_circle(beam_end,13.0*beam_alpha,Color(0.2,0.95,1.0,beam_alpha*0.45))
			draw_circle(beam_end,4.0*beam_alpha,Color.WHITE)
		elif fx.has("vel"):
			fx["pos"] += fx["vel"] * get_process_delta_time()
			draw_rect(Rect2(fx["pos"],Vector2(fx["radius"],fx["radius"])),fx["color"])
		else:
			var alpha := clampf(float(fx["life"])/float(fx["max_life"]),0,1)
			draw_circle(fx["pos"], float(fx["radius"])*(1.0-alpha*0.35), Color(fx["color"].r,fx["color"].g,fx["color"].b,alpha), false, 3.0)
	# A few drifting digital scanlines give the sector a corrupted-engine atmosphere.
	for scan_i in range(4):
		var scan_y := fposmod(elapsed * (22.0 + scan_i * 4.0) + scan_i * 173.0, 560.0) + 100.0
		draw_line(Vector2(42, scan_y), Vector2(1238, scan_y), Color(0.10,0.75,0.9,0.035), 1.0)
	# Player ground shadow and directional energy halo.
	draw_custom_ellipse(player_pos + Vector2(0,27), Vector2(29,10), Color(0.0,0.0,0.0,0.48))
	draw_circle(player_pos, 44, Color(0.04,0.72,0.9,0.10))
	draw_circle(player_pos, 31, Color(0.04,0.72,0.9,0.05))
	# Eight-direction idle/walk animation, ported from the Pygame asset pack.
	var direction_name := _facing_name(player_facing)
	var frame_list: Array = walk_frames.get(direction_name, []) if player_moving else idle_frames.get(direction_name, [])
	if frame_list.is_empty():
		frame_list = idle_frames.get("south", [])
	if not frame_list.is_empty():
		var frame_index := int(elapsed * (12.0 if player_moving else 4.0)) % frame_list.size()
		var sprite: Texture2D = frame_list[frame_index]
		draw_texture_rect(sprite, Rect2(player_pos - Vector2(48,48), Vector2(96,96)), false)
	else:
		draw_circle(player_pos, 15, Color("#47eaff"))
		draw_circle(player_pos, 6, Color.WHITE)

	if invulnerability > 0:
		draw_circle(player_pos, 24, Color(1,0.2,0.35,0.45), false, 3.0)
	# Pygame v10-inspired corruption transition when the boss awakens.
	if boss_spawned:
		var red_alpha := 0.12 + 0.035 * (0.5 + 0.5 * sin(corruption_pulse * 3.2))
		draw_rect(Rect2(Vector2.ZERO,WORLD_SIZE),Color(0.48,0.015,0.055,red_alpha))
		for crack_i in range(9):
			var crack_x := fposmod(float(crack_i*271)+corruption_pulse*42.0,WORLD_SIZE.x)
			var crack_y := fposmod(float(crack_i*173)+sin(corruption_pulse+crack_i)*80.0,WORLD_SIZE.y)
			draw_line(Vector2(crack_x,crack_y),Vector2(crack_x+26,crack_y+12),Color(1.0,0.06,0.18,0.30),2.0)
	# aim reticle
	draw_circle(aim_pos, 8, Color(0.1,0.95,1.0,0.8), false, 1.5)
	draw_line(aim_pos+Vector2(-13,0),aim_pos+Vector2(13,0),Color(0.1,0.95,1.0,0.5),1)
	draw_line(aim_pos+Vector2(0,-13),aim_pos+Vector2(0,13),Color(0.1,0.95,1.0,0.5),1)
	_draw_fog()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_hud()

func _draw_landmarks() -> void:
	if level_index == 1:
		# The Null Foundry's three heat exchangers frame a long industrial route.
		for i in range(3):
			var center: Vector2 = [Vector2(530, 420), Vector2(1260, 420), Vector2(1870, 900)][i]
			var pulse := 0.5 + 0.5 * sin(elapsed * 2.0 + float(i))
			draw_custom_ellipse(center + Vector2(0,20), Vector2(78,25), Color(0,0,0,0.4))
			draw_arc(center, 58 + pulse * 5, elapsed * 0.25 + i, elapsed * 0.25 + i + TAU * 0.8, 48, Color("#ff365f",0.75), 3.0)
			draw_arc(center, 39, -elapsed * 0.4, -elapsed * 0.4 + TAU * 0.7, 40, Color("#6c4cff",0.85), 2.0)
			for shard_i in range(7):
				var a := float(shard_i) * TAU / 7.0
				var tip: Vector2 = center + Vector2(cos(a), sin(a)) * 45.0
				draw_colored_polygon(PackedVector2Array([tip+Vector2(-5,8),tip+Vector2(0,-17),tip+Vector2(6,8)]), Color("#263d61"))
				draw_line(tip+Vector2(0,3),tip+Vector2(0,-11),Color("#ff477d",0.9),1.5)
			draw_string(ThemeDB.fallback_font, center + Vector2(-85,82), ["COOLANT EXCHANGE", "SENTINEL FOUNDRY", "OVERLORD APPROACH"][i], HORIZONTAL_ALIGNMENT_CENTER, 170, 10, Color("#ff9bb9"))
		return
	# Hand-authored landmarks make the level readable like an explorable island, not a random obstacle field.
	# The shapes are original: broken signal shrines, crystalline data growth and a sunken relay ring.
	# Central upgrade shrine
	var shrine := Vector2(1110,820)
	draw_custom_ellipse(shrine+Vector2(0,20),Vector2(76,28),Color(0.0,0.0,0.0,0.34))
	draw_arc(shrine,58,elapsed*0.18,elapsed*0.18+TAU*0.84,48,Color(0.18,0.78,0.92,0.55),2.0)
	draw_arc(shrine,42,-elapsed*0.24,-elapsed*0.24+TAU*0.65,40,Color(0.73,0.24,0.96,0.55),2.0)
	for shard_i in range(6):
		var a := float(shard_i)*TAU/6.0
		var base := shrine+Vector2(cos(a),sin(a))*44.0
		draw_colored_polygon(PackedVector2Array([base+Vector2(-5,8),base+Vector2(0,-15),base+Vector2(6,8)]),Color("#24566b"))
		draw_line(base+Vector2(0,2),base+Vector2(0,-10),Color("#59f6ef"),1.5)
	draw_string(ThemeDB.fallback_font,shrine+Vector2(-80,82),"THE SIGNAL SHRINE",HORIZONTAL_ALIGNMENT_CENTER,160,10,Color("#83dce8"))
	# A shattered bridge over corrupted water, placed near the northern pond.
	var relay := Vector2(1380,340)
	draw_custom_ellipse(relay+Vector2(0,14),Vector2(68,21),Color(0.0,0.0,0.0,0.30))
	draw_arc(relay,48,0.25,PI*1.75,32,Color("#4ce9f0",0.8),4.0)
	draw_arc(relay,34,PI,TAU+PI*0.3,32,Color("#9c45ff",0.75),2.0)
	for shard_i in range(5):
		var sx := relay.x-46.0+float(shard_i)*22.0
		var sy := relay.y+sin(float(shard_i)*1.4)*10.0
		draw_colored_polygon(PackedVector2Array([Vector2(sx-5,sy+8),Vector2(sx,sy-12-float(shard_i%2)*7),Vector2(sx+5,sy+8)]),Color("#236c83"))
		draw_line(Vector2(sx,sy+2),Vector2(sx,sy-8),Color("#79fff2"),1.0)
	draw_string(ThemeDB.fallback_font,relay+Vector2(-68,58),"SUNKEN RELAY",HORIZONTAL_ALIGNMENT_CENTER,136,10,Color("#78eaf0"))
	# A broken crystal grove in the southern sector, with distinct violet corruption.
	var grove := Vector2(1770,1110)
	draw_custom_ellipse(grove+Vector2(0,15),Vector2(92,31),Color(0.0,0.0,0.0,0.32))
	for crystal_i in range(9):
		var offset := Vector2(float((crystal_i%3)-1)*31.0, float(crystal_i/3)*-18.0)
		var tip := grove+offset+Vector2(float((crystal_i%2)*8-4),-20.0-float(crystal_i%3)*8.0)
		var foot := grove+offset+Vector2(0,13)
		draw_colored_polygon(PackedVector2Array([foot+Vector2(-8,0),tip,foot+Vector2(8,0)]),Color("#382d68"))
		draw_colored_polygon(PackedVector2Array([tip,foot+Vector2(1,0),foot+Vector2(6,0)]),Color("#9a46e9"))
		draw_line(tip,foot+Vector2(0,0),Color("#e39cff",0.9),1.0)
	draw_string(ThemeDB.fallback_font,grove+Vector2(-78,50),"FRACTURE GROVE",HORIZONTAL_ALIGNMENT_CENTER,156,10,Color("#d8a2ff"))

func _draw_gate() -> void:
	# The extraction gate is a reward reveal: invisible until the boss falls.
	if not _boss_is_defeated():
		return
	var pulse := 0.5 + 0.5 * sin(elapsed * 3.4)
	var center := exit_pos
	# Ground glyph and broken outer ring.
	draw_custom_ellipse(center + Vector2(0, 30), Vector2(72, 20), Color(0.0, 0.0, 0.0, 0.45))
	draw_arc(center, 58.0 + pulse * 5.0, elapsed * 0.7, elapsed * 0.7 + TAU * 0.82, 64, Color(0.15, 0.88, 1.0, 0.78), 3.0)
	draw_arc(center, 45.0, -elapsed * 1.1, -elapsed * 1.1 + TAU * 0.66, 48, Color(0.88, 0.18, 1.0, 0.72), 2.0)
	# Tall fractured portal frame, with deliberately broken corners.
	var frame_color := Color(0.25, 0.95, 1.0, 0.7 + pulse * 0.3)
	draw_line(center + Vector2(-28, 42), center + Vector2(-28, -46), frame_color, 4.0, true)
	draw_line(center + Vector2(-28, -46), center + Vector2(-10, -58), frame_color, 4.0, true)
	draw_line(center + Vector2(28, -40), center + Vector2(28, 46), frame_color, 4.0, true)
	draw_line(center + Vector2(28, 46), center + Vector2(8, 58), frame_color, 4.0, true)
	# Portal interior: animated vertical energy ribbons and a bright core.
	for ribbon_i in range(7):
		var rx := center.x - 20.0 + float(ribbon_i) * 6.5
		var sway := sin(elapsed * 4.0 + float(ribbon_i) * 0.8) * 5.0
		var top := center.y - 39.0 + absf(sway)
		var bottom := center.y + 39.0 - absf(sway)
		draw_line(Vector2(rx, top), Vector2(rx + sway, bottom), Color(0.18, 0.86 + float(ribbon_i % 2) * 0.12, 1.0, 0.12 + pulse * 0.18), 5.0, true)
		draw_line(Vector2(rx, top), Vector2(rx + sway, bottom), Color(0.78, 0.98, 1.0, 0.45 + pulse * 0.35), 1.2, true)
	draw_circle(center, 17.0 + pulse * 5.0, Color(0.12, 0.86, 1.0, 0.13))
	draw_circle(center, 7.0 + pulse * 2.0, Color(0.86, 0.97, 1.0, 0.8))
	for spark_i in range(8):
		var a := elapsed * 1.4 + TAU * float(spark_i) / 8.0
		var spark_pos := center + Vector2(cos(a) * (39.0 + sin(elapsed * 2.0 + spark_i) * 5.0), sin(a) * 52.0)
		draw_circle(spark_pos, 2.0 + pulse, Color(0.45, 0.95, 1.0, 0.85))
	draw_string(ThemeDB.fallback_font, center + Vector2(-90, 82), ("FOUNDRY EXIT // UNLOCKED" if level_index == 1 else "EXTRACTION // UNLOCKED"), HORIZONTAL_ALIGNMENT_CENTER, 180, 11, Color(0.45, 0.96, 1.0))

func _draw_hud() -> void:
	draw_rect(Rect2(0,0,1280,82), Color(0.015,0.025,0.045,0.97))
	draw_line(Vector2(0,82),Vector2(1280,82),Color("#1c6678"),2)
	draw_string(ThemeDB.fallback_font, Vector2(24,32), "RA.ONE  //  THE CORRUPTED ENGINE", HORIZONTAL_ALIGNMENT_LEFT, 360, 20, Color("#58eaff"))
	draw_string(ThemeDB.fallback_font, Vector2(24,59), ("LEVEL 2  •  THE NULL FOUNDRY" if level_index == 1 else "LEVEL 1  •  THE AWAKENING"), HORIZONTAL_ALIGNMENT_LEFT, 450, 13, Color("#d2a9cb" if level_index == 1 else "#9eb8c8"))
	var drones_left := 0
	for enemy in enemies:
		if not enemy["boss"] and enemy["alive"]: drones_left += 1
	draw_string(ThemeDB.fallback_font, Vector2(390,58), "DRONES %02d" % drones_left, HORIZONTAL_ALIGNMENT_LEFT, 120, 12, Color("#ff6d82"))
	draw_string(ThemeDB.fallback_font, Vector2(510,30), "HP", HORIZONTAL_ALIGNMENT_LEFT, 30, 13, Color("#ff526f"))
	draw_rect(Rect2(541,13,178,24), Color("#07101b"))
	draw_rect(Rect2(545,17,170,16), Color("#321827"))
	draw_rect(Rect2(545,17,170*float(player_hp)/float(player_max_hp),16), Color("#ff3158"))
	draw_string(ThemeDB.fallback_font, Vector2(730,30), "%d / %d" % [player_hp, player_max_hp], HORIZONTAL_ALIGNMENT_LEFT, 90, 13, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(855,30), "DATA  %03d" % data_fragments, HORIZONTAL_ALIGNMENT_LEFT, 140, 15, Color("#d858ff"))
	var weapon_text := "UNARMED" if selected_weapon == "" else "%s  [LV %d]" % [selected_weapon.to_upper(), int(weapon_levels.get(selected_weapon,1))]
	draw_string(ThemeDB.fallback_font, Vector2(855,57), weapon_text, HORIZONTAL_ALIGNMENT_LEFT, 350, 13, Color("#b6faff"))
	draw_string(ThemeDB.fallback_font, Vector2(24,704), "WASD MOVE  •  MOUSE FIRE  •  SHIFT+CLICK RAIL  •  SPACE DASH  •  E WORKBENCH  •  X SWITCH WEAPON  •  TAB CGG", HORIZONTAL_ALIGNMENT_LEFT, 1200, 12, Color("#7c9aaa"))
	if message_time > 0:
		var alpha := clampf(message_time,0,1)
		draw_rect(Rect2(330,94,620,34), Color(0.02,0.06,0.1,0.9))
		draw_string(ThemeDB.fallback_font, Vector2(340,116), message, HORIZONTAL_ALIGNMENT_CENTER, 600, 15, Color(0.45,0.95,1.0,alpha))
	# Persistent explored minimap: unexplored cells remain hidden and enemies appear only in sight.
	draw_rect(Rect2(1090,94,165,100), Color(0.015,0.025,0.045,0.97))
	draw_rect(Rect2(1090,94,165,100), Color("#236071"), false, 1.0)
	var inner := Rect2(1095,99,155,90)
	for cell in explored_cells.keys():
		var world_cell: Vector2i = cell
		var mini_rect := Rect2(inner.position.x + float(world_cell.x * 32) / WORLD_SIZE.x * inner.size.x, inner.position.y + float(world_cell.y * 32) / WORLD_SIZE.y * inner.size.y, 1.5, 1.5)
		draw_rect(mini_rect, Color("#315365"))
	for e in enemies:
		if e["alive"] and player_pos.distance_to(e["pos"]) < 220.0:
			var p: Vector2 = e["pos"]
			var mp := Vector2(inner.position.x + p.x / WORLD_SIZE.x * inner.size.x, inner.position.y + p.y / WORLD_SIZE.y * inner.size.y)
			draw_circle(mp, 2.5 if not e["boss"] else 3.5, Color("#ff3158") if not e["boss"] else Color("#d858ff"))
	draw_circle(Vector2(inner.position.x + player_pos.x / WORLD_SIZE.x * inner.size.x, inner.position.y + player_pos.y / WORLD_SIZE.y * inner.size.y), 2.5, Color("#55f2ff"))
	# Boss bar only appears while the Level 1 spider-mech is alive.
	for e in enemies:
		if e["boss"] and e["alive"]:
			draw_rect(Rect2(420,88,440,20), Color(0.04,0.025,0.06,0.96))
			draw_string(ThemeDB.fallback_font, Vector2(430,102), ("CHAOS OVERLORD // CORE INTEGRITY" if level_index == 1 else "SPIDER-MECH // CORE INTEGRITY"), HORIZONTAL_ALIGNMENT_LEFT, 250, 11, Color("#ff5278"))
			draw_rect(Rect2(650,94,190,8), Color("#351827"))
			draw_rect(Rect2(650,94,190.0 * clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0),8), Color("#ff3158"))
	# Upgrade terminal hint remains contextual, not a sidebar.
	var terminal_screen := terminal_pos - camera_pos + SCREEN * 0.5
	if terminal_screen.x > 80 and terminal_screen.x < 1040 and terminal_screen.y > 110 and terminal_screen.y < 650:
		draw_string(ThemeDB.fallback_font, terminal_screen + Vector2(-50,-38), "UPGRADE TERMINAL", HORIZONTAL_ALIGNMENT_LEFT, 220, 11, Color("#53eaff"))
		draw_string(ThemeDB.fallback_font, terminal_screen + Vector2(-50,-22), "E // OPEN WORKBENCH", HORIZONTAL_ALIGNMENT_LEFT, 220, 10, Color("#8baab9"))
	if upgrade_menu_open:
		_draw_weapon_workbench()

func _draw_weapon_workbench() -> void:
	draw_rect(Rect2(0, 0, SCREEN.x, SCREEN.y), Color(0.005, 0.008, 0.02, 0.72))
	var panel := Rect2(300, 100, 680, 520)
	draw_colored_polygon(_beveled_points(panel, 18.0), Color("#071321"))
	_draw_closed_outline(_beveled_points(panel, 18.0), Color("#49eaff"), 2.0)
	draw_rect(Rect2(300, 100, 8, 520), Color("#ff3158"))
	draw_string(ThemeDB.fallback_font, Vector2(350, 155), "ARMORY // WEAPON WORKBENCH", HORIZONTAL_ALIGNMENT_LEFT, 570, 27, Color("#64f2ff"))
	draw_string(ThemeDB.fallback_font, Vector2(350, 190), "DATA SHARDS AVAILABLE: %03d" % data_fragments, HORIZONTAL_ALIGNMENT_LEFT, 560, 16, Color("#d858ff"))
	var names := ["Pulse Gun", "Laser Blade", "Rail Blaster", "Nova Core"]
	for i in range(names.size()):
		var w: String = names[i]
		var row := Rect2(345, 220 + i * 62, 590, 52)
		var owned: bool = owned_weapons.has(w)
		var active: bool = selected_weapon == w
		draw_rect(row, Color(0.025, 0.09, 0.13, 0.96) if active else Color(0.015, 0.035, 0.06, 0.94))
		draw_rect(row, Color("#55efff") if active else Color("#29495c"), false, 1.2)
		var lvl: int = int(weapon_levels.get(w, 1))
		var cost: int = 20 * lvl
		draw_string(ThemeDB.fallback_font, row.position + Vector2(16, 22), w.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 220, 15, Color.WHITE if owned else Color("#607887"))
		draw_string(ThemeDB.fallback_font, row.position + Vector2(16, 42), ("EQUIPPED" if active else ("OWNED" if owned else "NOT ACQUIRED")), HORIZONTAL_ALIGNMENT_LEFT, 200, 10, Color("#60efff" if active else "#9cb3c3"))
		draw_string(ThemeDB.fallback_font, row.position + Vector2(280, 30), ("LV %02d / 03" % lvl if owned else "—"), HORIZONTAL_ALIGNMENT_LEFT, 120, 14, Color("#d9f8ff"))
		draw_string(ThemeDB.fallback_font, row.position + Vector2(400, 30), (("MAX LEVEL" if lvl >= 3 else "UPGRADE %d SHARDS" % cost) if owned else "LOCKED"), HORIZONTAL_ALIGNMENT_LEFT, 170, 12, Color("#d858ff" if owned else "#607887"))
	draw_string(ThemeDB.fallback_font, Vector2(350, 510), "E // BUY UPGRADE FOR EQUIPPED WEAPON", HORIZONTAL_ALIGNMENT_LEFT, 420, 13, Color("#6cf3ff"))
	draw_string(ThemeDB.fallback_font, Vector2(350, 545), "X // CYCLE WEAPON     1-4 // DIRECT SELECT     ESC // CLOSE", HORIZONTAL_ALIGNMENT_LEFT, 580, 12, Color("#a4bdcc"))
	draw_string(ThemeDB.fallback_font, Vector2(350, 585), "THREE WEAPON LEVELS // EACH UPGRADE BOOSTS DAMAGE.", HORIZONTAL_ALIGNMENT_LEFT, 580, 12, Color("#718fa1"))

func _draw_fog() -> void:
	# Fog follows explored cells: nearby terrain is clear, explored terrain remains dim, unknown is hidden.
	var min_x := maxi(0, int((camera_pos.x - SCREEN.x * 0.5) / 32.0) * 32 - 32)
	var max_x := mini(int(WORLD_SIZE.x), int((camera_pos.x + SCREEN.x * 0.5) / 32.0) * 32 + 64)
	var min_y := maxi(0, int((camera_pos.y - SCREEN.y * 0.5) / 32.0) * 32 - 32)
	var max_y := mini(int(WORLD_SIZE.y), int((camera_pos.y + SCREEN.y * 0.5) / 32.0) * 32 + 64)
	for y in range(min_y, max_y, 32):
		for x in range(min_x, max_x, 32):
			var center := Vector2(x+16,y+16)
			var key := Vector2i(int(x/32),int(y/32))
			var distance_to_player := center.distance_to(player_pos)
			if distance_to_player <= 190.0:
				continue
			var target_alpha := 0.43 if explored_cells.has(key) else 0.83
			# Fade the fog over a wider radius to avoid a hard-edged square visibility bubble.
			var fade := clampf((distance_to_player - 190.0) / 150.0, 0.0, 1.0)
			var alpha := target_alpha * fade
			if alpha > 0.01:
				draw_rect(Rect2(x,y,32,32), Color(0.012,0.018,0.045,alpha))
	draw_circle(player_pos, 250.0, Color(0.1,0.78,0.95,0.10), false, 2.0)

func _update_exploration() -> void:
	var min_x := maxi(0, int((player_pos.x-270.0)/32.0)*32)
	var max_x := mini(int(WORLD_SIZE.x), int((player_pos.x+270.0)/32.0)*32+32)
	var min_y := maxi(0, int((player_pos.y-270.0)/32.0)*32)
	var max_y := mini(int(WORLD_SIZE.y), int((player_pos.y+270.0)/32.0)*32+32)
	for y in range(min_y,max_y,32):
		for x in range(min_x,max_x,32):
			if Vector2(x+16,y+16).distance_to(player_pos) <= 270.0:
				explored_cells[Vector2i(int(x/32),int(y/32))] = true

func _terrain_index(x: int, y: int) -> int:
	var tx := int(x / 32); var ty := int(y / 32)
	if level_index == 1:
		# Steel-foundry lanes, coolant pools, and dark slag fields.
		var foundry_lane: bool = abs(ty - (13 + int(2.0 * sin(float(tx) * 0.21)))) <= 1
		if foundry_lane or (tx > 20 and tx < 25 and ty > 13 and ty < 34) or (tx > 44 and tx < 50 and ty > 7 and ty < 24): return 1
		for pool in [Vector2(16,10), Vector2(33,35), Vector2(56,14), Vector2(50,39)]:
			if Vector2(float(tx),float(ty)).distance_to(pool) < 3.4 + 0.8 * sin(float(tx*3+ty*5)): return 3
		if (tx > 8 and tx < 16 and ty > 25 and ty < 32) or (tx > 30 and tx < 38 and ty > 5 and ty < 11) or (tx > 53 and ty > 27 and ty < 34): return 2
		return 0
	# Organic overworld: winding sandy trail, stone ruins, and irregular pixel-art ponds.
	var path_y: int = 15 - int(2.0 * sin(float(tx) * 0.18))
	if tx > 22: path_y = 15 - int(4.0 * sin(float(tx) * 0.19)) + (2 if tx > 43 else 0)
	var on_path: bool = abs(ty-path_y) <= 1 or (tx>25 and tx<33 and ty>7 and ty<15) or (tx>44 and tx<51 and ty>17 and ty<22)
	if on_path: return 1
	var ponds := [Vector2(12,31),Vector2(43,8),Vector2(54,35),Vector2(31,42)]
	for i in range(ponds.size()):
		var pond: Vector2 = ponds[i]
		var wobble := 1.1 * sin(float(tx*(i+2)+ty*3)*0.47)
		if Vector2(float(tx),float(ty)).distance_to(pond) < 4.0+wobble: return 3
	if (tx>18 and tx<26 and ty>3 and ty<9) or (tx>37 and tx<43 and ty>28 and ty<34) or (tx>57 and ty>23 and ty<31): return 2
	return 0

func _draw_terrain_props() -> void:
	# Irregularly distributed pixel-art trees, rocks and data flora; no repeating grid pattern.
	var first_tx := maxi(1,int((camera_pos.x-SCREEN.x*0.5)/32.0)-2); var last_tx := mini(71,int((camera_pos.x+SCREEN.x*0.5)/32.0)+3)
	var first_ty := maxi(1,int((camera_pos.y-SCREEN.y*0.5)/32.0)-2); var last_ty := mini(50,int((camera_pos.y+SCREEN.y*0.5)/32.0)+3)
	for tx in range(first_tx,last_tx):
		for ty in range(first_ty,last_ty):
			var seed_value := posmod(tx*37+ty*61+tx*ty*13,101)
			if _terrain_index(tx*32+16,ty*32+16) != 0: continue
			var p := Vector2(tx*32+16,ty*32+16)
			if seed_value < 9:
				draw_custom_ellipse(p+Vector2(0,13),Vector2(20,7),Color(0.0,0.0,0.0,0.34))
				if tree_texture:
					# Tint the original organic tree into a data-corrupted organism, not ordinary woodland.
					var tree_tint := (Color("#a4a8ff") if seed_value % 3 != 0 else Color("#ff6cbd")) if level_index == 1 else (Color(0.64,1.0,1.0,1.0) if seed_value % 3 != 0 else Color(0.95,0.63,1.0,1.0))
					draw_texture_rect(tree_texture,Rect2(p-Vector2(31,40),Vector2(62,62)),false,tree_tint)
				else:
					draw_rect(Rect2(p.x-4,p.y-13,8,22),Color("#315c68")); draw_rect(Rect2(p.x-16,p.y-31,32,24),Color("#1b777b")); draw_rect(Rect2(p.x-11,p.y-37,23,20),Color("#45c7c2"))
				# Data veins and a few floating pixel motes.
				draw_line(p+Vector2(-5,-5),p+Vector2(-1,-14),Color("#56f5e7",0.65),1.0)
				draw_line(p+Vector2(2,-9),p+Vector2(7,-17),Color("#b85dff",0.55),1.0)
				draw_circle(p+Vector2(13,-20),2.0,Color("#70fff2",0.75))
			elif seed_value >= 10 and seed_value < 14:
				draw_custom_ellipse(p+Vector2(0,5),Vector2(15,7),Color(0.0,0.0,0.0,0.22))
				draw_colored_polygon(PackedVector2Array([p+Vector2(-13,4),p+Vector2(-10,-5),p+Vector2(-2,-12),p+Vector2(8,-9),p+Vector2(14,2),p+Vector2(7,8),p+Vector2(-8,8)]),Color("#394a61"))
				draw_line(p+Vector2(-7,1),p+Vector2(1,-7),Color("#52e9e8"),2.0)
				draw_rect(Rect2(p.x+3,p.y-4,4,3),Color("#c14dff"))
			elif seed_value >= 15 and seed_value < 18:
				draw_rect(Rect2(p.x-4,p.y-11,8,15),Color("#1d6579")); draw_rect(Rect2(p.x-2,p.y-15,4,5),Color("#68fff0")); draw_circle(p,12,Color(0.12,0.9,0.82,0.08))
				draw_line(p+Vector2(-8,0),p+Vector2(8,0),Color("#3adce7",0.55),1.0)

func _facing_name(direction: Vector2) -> String:
	var fx := direction.x
	var fy := direction.y
	if absf(fx) < 0.25:
		return "south" if fy >= 0.0 else "north"
	if absf(fy) < 0.25:
		return "east" if fx >= 0.0 else "west"
	if fx >= 0.0:
		return "south-east" if fy >= 0.0 else "north-east"
	return "south-west" if fy >= 0.0 else "north-west"

func _load_character_frames(animation_name: String, direction: String) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	var folder := "res://assets/character/animations/%s/%s" % [animation_name, direction]
	var dir := DirAccess.open(folder)
	if dir == null:
		return result
	var files := dir.get_files()
	files.sort()
	for file_name in files:
		if file_name.to_lower().ends_with(".png"):
			var tex := load(folder + "/" + file_name) as Texture2D
			if tex != null:
				result.append(tex)
	return result

func _create_smoke_texture() -> Texture2D:
	# A soft procedural cloud texture: no pixel particles or hard-edged glitch squares.
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var noise := FastNoiseLite.new()
	noise.seed = 8117
	noise.frequency = 0.035
	noise.fractal_octaves = 3
	noise.fractal_gain = 0.58
	for y in range(128):
		for x in range(128):
			var nx := (float(x) - 63.5) / 63.5
			var ny := (float(y) - 63.5) / 63.5
			var radius := sqrt(nx * nx + ny * ny)
			var edge_fade := clampf(1.0 - radius, 0.0, 1.0)
			var cloud_noise := (noise.get_noise_2d(float(x), float(y)) + 1.0) * 0.5
			var cloud_density := clampf((cloud_noise - 0.27) * 1.65, 0.0, 1.0)
			var alpha := pow(edge_fade, 0.72) * cloud_density * 0.82
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)

func _draw_hover_smoke(r: Rect2, pulse: float) -> void:
	if smoke_texture == null:
		return
	# Slow, layered wisps drift away from the energized red edge and across the tile.
	for i in range(8):
		var phase := elapsed * (0.52 + float(i % 3) * 0.09) + float(i) * 1.17
		var drift_x := sin(phase * 0.82) * (9.0 + float(i % 3) * 4.0)
		var rise := fposmod(elapsed * (13.0 + float(i % 4) * 2.0) + float(i) * 19.0, 62.0)
		var puff_size := Vector2(82.0 + float(i % 3) * 15.0, 48.0 + float(i % 4) * 9.0)
		var puff_pos := Vector2(r.position.x - 24.0 + float(i % 4) * 73.0 + drift_x, r.position.y + 9.0 + float(i % 2) * 21.0 - rise)
		var tint := Color(0.16, 0.66, 1.0, 0.19 * pulse)
		if i % 3 == 0:
			tint = Color(0.96, 0.12, 0.28, 0.13 * pulse)
		draw_texture_rect(smoke_texture, Rect2(puff_pos, puff_size), false, tint)

func _draw_title() -> void:
	# Artwork-only background. The logo, menu, hover lighting and music control are rendered independently.
	if title_texture != null:
		draw_texture_rect(title_texture, Rect2(Vector2.ZERO, SCREEN), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("#050a16"))

	# Soft readability wash at the left, without a surrounding menu panel.
	for band in range(14):
		var alpha := 0.105 * (1.0 - float(band) / 14.0)
		draw_rect(Rect2(float(band) * 34.0, 170.0, 34.0, 470.0), Color(0.005, 0.018, 0.035, alpha))

	var logo_font: Font = ui_font if ui_font != null else ThemeDB.fallback_font
	if logo_texture != null:
		draw_texture_rect(logo_texture, Rect2(Vector2(47, 137), Vector2(535, 178)), false)
	else:
		draw_string(logo_font, Vector2(77, 251), "RA.ONE", HORIZONTAL_ALIGNMENT_LEFT, 540, 70, Color("#eafaff"))
		draw_string(logo_font, Vector2(83, 302), "THE CORRUPTED ENGINE", HORIZONTAL_ALIGNMENT_LEFT, 430, 20, Color("#ff536d"))

	var labels := ["START", "SETTINGS", "CREDITS", "EXIT"]
	for i in range(labels.size()):
		var r := _title_button_rect(i)
		var hovered := i == menu_hover_index
		var points := _beveled_points(r, 11.0)
		if hovered:
			var pulse := 0.78 + 0.22 * sin(elapsed * 3.8)
			# Smoke and bloom are drawn behind the tile, so the label stays crisp.
			_draw_hover_smoke(r, pulse)
			for glow_layer in range(7, 0, -1):
				var spread := float(glow_layer) * 4.2
				var glow_rect := Rect2(r.position - Vector2(spread, spread * 0.62), r.size + Vector2(spread * 2.0, spread * 1.24))
				var glow_alpha := (0.012 + 0.008 * pulse) * float(8 - glow_layer)
				draw_colored_polygon(_beveled_points(glow_rect, 12.0 + spread * 0.35), Color(0.015, 0.55, 1.0, glow_alpha))
				_draw_closed_outline(_beveled_points(glow_rect, 12.0 + spread * 0.35), Color(0.04, 0.62, 1.0, 0.025 * float(8 - glow_layer) * pulse), 2.0 + float(glow_layer) * 0.25)
			# The tile fill is glassy and translucent, with no outer menu frame.
			draw_colored_polygon(points, Color(0.005, 0.095, 0.16, 0.78))
			_draw_closed_outline(points, Color(0.20, 0.94, 1.0, 1.0), 2.2)
			draw_line(Vector2(r.position.x + 18, r.position.y + 1), Vector2(r.end.x - 28, r.position.y + 1), Color(0.35, 0.98, 1.0, 0.95), 2.0)
			draw_line(Vector2(r.position.x + 25, r.end.y - 1), Vector2(r.end.x - 42, r.end.y - 1), Color(0.04, 0.62, 1.0, 0.78), 1.5)
			# Glowing red accent strip: soft bloom first, bright core last.
			var accent_x := r.position.x + 1.5
			var accent_top := r.position.y + 8.0
			var accent_bottom := r.end.y - 9.0
			draw_line(Vector2(accent_x, accent_top), Vector2(accent_x, accent_bottom), Color(1.0, 0.035, 0.18, 0.12 * pulse), 15.0)
			draw_line(Vector2(accent_x, accent_top), Vector2(accent_x, accent_bottom), Color(1.0, 0.035, 0.18, 0.22 * pulse), 9.0)
			draw_line(Vector2(accent_x, accent_top), Vector2(accent_x, accent_bottom), Color(1.0, 0.07, 0.24, 0.75 * pulse), 4.0)
			draw_line(Vector2(accent_x, accent_top), Vector2(accent_x, accent_bottom), Color(1.0, 0.58, 0.67, 0.95 * pulse), 1.3)
		else:
			draw_colored_polygon(points, Color(0.005, 0.025, 0.045, 0.46))
			_draw_closed_outline(points, Color(0.32, 0.68, 0.82, 0.88), 1.2)
		var icon_color := Color("#8af5ff") if hovered else Color("#a8cce0")
		var label_color := Color("#f2fdff") if hovered else Color("#c1d8e7")
		draw_string(logo_font, Vector2(r.position.x + 23, r.position.y + 34), "◇", HORIZONTAL_ALIGNMENT_LEFT, 24, 20, icon_color)
		draw_string(logo_font, Vector2(r.position.x + 61, r.position.y + 33), labels[i], HORIZONTAL_ALIGNMENT_LEFT, 230, 18, label_color)

	# Music toggle remains independent in the top-right.
	var mr := _music_button_rect()
	var mp := _beveled_points(mr, 8.0)
	draw_colored_polygon(mp, Color(0.005, 0.025, 0.045, 0.43))
	_draw_closed_outline(mp, Color(0.18, 0.82, 1.0, 0.88), 1.3)
	draw_string(logo_font, Vector2(mr.position.x + 13, mr.position.y + 26), "♫  MUSIC " + ("OFF" if music_muted else "ON"), HORIZONTAL_ALIGNMENT_LEFT, 150, 13, Color("#ff6c91") if music_muted else Color("#8df6ff"))

func _draw_story_intro() -> void:
	_draw_story_page(false)

func _draw_story_page(archive_mode: bool) -> void:
	if title_texture != null:
		draw_texture_rect(title_texture, Rect2(Vector2.ZERO, SCREEN), false)
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.002, 0.008, 0.018, 0.74))
	for i in range(12):
		var scan_y: float = fposmod(float(i) * 67.0 + elapsed * 17.0, 720.0)
		draw_line(Vector2(0, scan_y), Vector2(1280, scan_y), Color(0.06, 0.72, 0.95, 0.035), 1.0)
	var frame := Rect2(90, 105, 1100, 535)
	var frame_points: PackedVector2Array = _beveled_points(frame, 15.0)
	draw_colored_polygon(frame_points, Color(0.004, 0.018, 0.034, 0.97))
	_draw_closed_outline(frame_points, Color(0.12, 0.82, 1.0, 0.92), 1.8)
	draw_rect(Rect2(90, 120, 7, 505), Color("#ff3158"))
	var chapter: Dictionary = story_cards[clampi(story_index, 0, story_cards.size() - 1)]
	draw_string(ThemeDB.fallback_font, Vector2(125, 145), str(chapter["eyebrow"]), HORIZONTAL_ALIGNMENT_LEFT, 620, 13, Color("#ff5573"))
	draw_string(ThemeDB.fallback_font, Vector2(125, 177), str(chapter["headline"]), HORIZONTAL_ALIGNMENT_LEFT, 760, 26, Color("#69efff"))
	# Each chapter is a separate illustration; the former paragraph overlay is intentionally removed.
	var art_rect := Rect2(125, 195, 770, 433)
	draw_rect(Rect2(art_rect.position - Vector2(4, 4), art_rect.size + Vector2(8, 8)), Color(0.025, 0.12, 0.17, 1.0))
	if story_textures.size() > story_index and story_textures[story_index] != null:
		var comic: Texture2D = story_textures[story_index]
		var tex_size: Vector2 = comic.get_size()
		var fit_scale: float = minf(art_rect.size.x / tex_size.x, art_rect.size.y / tex_size.y)
		var fitted_size: Vector2 = tex_size * fit_scale
		var fitted_rect: Rect2 = Rect2(art_rect.position + (art_rect.size - fitted_size) * 0.5, fitted_size)
		draw_texture_rect(comic, fitted_rect, false)
	else:
		draw_rect(art_rect, Color(0.02, 0.04, 0.07, 1.0))
	_draw_closed_outline(_beveled_points(art_rect, 6.0), Color(0.18, 0.85, 1.0, 0.85), 1.2)
	# Right-side archive rail: chapter metadata and four-step progress, not story paragraphs.
	draw_string(ThemeDB.fallback_font, Vector2(925, 235), "ENGINE ARCHIVE", HORIZONTAL_ALIGNMENT_LEFT, 220, 12, Color("#82aabc"))
	draw_string(ThemeDB.fallback_font, Vector2(925, 270), "%02d  /  04" % (story_index + 1), HORIZONTAL_ALIGNMENT_LEFT, 220, 26, Color("#f4fbff"))
	draw_line(Vector2(925, 286), Vector2(1140, 286), Color(0.12, 0.8, 1.0, 0.42), 1.0)
	var chapter_labels: Array[String] = ["ENGINE BUILD", "AI INTEGRATION", "SYSTEM TAKEOVER", "PULLED INSIDE"]
	for i in range(chapter_labels.size()):
		var yy: float = 320.0 + float(i) * 34.0
		var active: bool = i == story_index
		draw_rect(Rect2(925, yy - 12, 5, 16), Color("#ff3158") if active else Color(0.12, 0.38, 0.48, 0.8))
		draw_string(ThemeDB.fallback_font, Vector2(940, yy), chapter_labels[i], HORIZONTAL_ALIGNMENT_LEFT, 200, 11, Color("#eafaff") if active else Color("#6e8fa1"))
	for i in range(4):
		var progress_color: Color = Color("#63efff") if i <= story_index else Color(0.18, 0.32, 0.4, 0.9)
		draw_rect(Rect2(925 + i * 51, 478, 39, 4), progress_color)
	draw_string(ThemeDB.fallback_font, Vector2(925, 515), "%02d%% DECRYPTED" % int(float(story_index + 1) / 4.0 * 100.0), HORIZONTAL_ALIGNMENT_LEFT, 220, 11, Color("#80b6c8"))
	if story_index > 0:
		var prev: Rect2 = _story_previous_rect()
		draw_colored_polygon(_beveled_points(prev, 7.0), Color(0.015, 0.07, 0.10, 1.0))
		_draw_closed_outline(_beveled_points(prev, 7.0), Color("#3b8ea3"), 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(prev.position.x, prev.position.y + 27), "PREVIOUS", HORIZONTAL_ALIGNMENT_CENTER, prev.size.x, 12, Color("#b8dce7"))
	var nxt: Rect2 = _story_next_rect()
	var next_points: PackedVector2Array = _beveled_points(nxt, 7.0)
	draw_colored_polygon(next_points, Color(0.02, 0.25, 0.33, 1.0))
	_draw_closed_outline(next_points, Color("#63efff"), 1.6)
	var next_label: String = "ENTER WORLD" if story_index == 3 and not archive_mode else ("RETURN" if story_index == 3 else "NEXT  →")
	draw_string(ThemeDB.fallback_font, Vector2(nxt.position.x, nxt.position.y + 27), next_label, HORIZONTAL_ALIGNMENT_CENTER, nxt.size.x, 12, Color("#f1fdff"))
	draw_string(ThemeDB.fallback_font, Vector2(125, 613), "CLICK THE ART OR NEXT  //  SPACE TO CONTINUE  //  ESC TO EXIT", HORIZONTAL_ALIGNMENT_LEFT, 670, 10, Color("#7397a8"))

func _draw_settings() -> void:
	if title_texture != null:
		draw_texture_rect(title_texture, Rect2(Vector2.ZERO, SCREEN), false)
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.002, 0.008, 0.018, 0.86))
	var panel := Rect2(230, 90, 820, 570)
	var points: PackedVector2Array = _beveled_points(panel, 16.0)
	draw_colored_polygon(points, Color(0.004, 0.018, 0.034, 0.97))
	_draw_closed_outline(points, Color("#50eaff"), 1.8)
	draw_rect(Rect2(230, 105, 7, 540), Color("#ff3158"))
	draw_string(ThemeDB.fallback_font, Vector2(275, 137), "SYSTEM CONFIGURATION", HORIZONTAL_ALIGNMENT_LEFT, 600, 12, Color("#ff5573"))
	draw_string(ThemeDB.fallback_font, Vector2(275, 178), "SETTINGS", HORIZONTAL_ALIGNMENT_LEFT, 600, 32, Color("#66efff"))
	draw_string(ThemeDB.fallback_font, Vector2(275, 205), "Tune the signal before entering the Engine.", HORIZONTAL_ALIGNMENT_LEFT, 600, 13, Color("#9db9ca"))
	# Audio card
	var audio_card := Rect2(270, 230, 740, 235)
	draw_rect(audio_card, Color(0.018, 0.055, 0.078, 0.94))
	_draw_closed_outline(_beveled_points(audio_card, 8.0), Color(0.12, 0.52, 0.65, 0.75), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(295, 258), "01  /  AUDIO MATRIX", HORIZONTAL_ALIGNMENT_LEFT, 400, 14, Color("#8ef5ff"))
	draw_string(ThemeDB.fallback_font, Vector2(295, 294), "MENU MUSIC", HORIZONTAL_ALIGNMENT_LEFT, 190, 13, Color.WHITE)
	var mute_rect := Rect2(790, 265, 120, 44)
	var mute_points: PackedVector2Array = _beveled_points(mute_rect, 7.0)
	draw_colored_polygon(mute_points, Color(0.04, 0.10, 0.13, 1.0) if settings_hover_index != 0 else Color(0.02, 0.26, 0.34, 1.0))
	_draw_closed_outline(mute_points, Color("#63efff") if settings_hover_index == 0 else Color("#387f92"), 1.2)
	draw_string(ThemeDB.fallback_font, Vector2(mute_rect.position.x, mute_rect.position.y + 27), "MUTED" if music_muted else "PLAYING", HORIZONTAL_ALIGNMENT_CENTER, mute_rect.size.x, 12, Color("#ff6c91") if music_muted else Color("#8df6ff"))
	draw_string(ThemeDB.fallback_font, Vector2(295, 337), "MUSIC LEVEL", HORIZONTAL_ALIGNMENT_LEFT, 200, 12, Color("#b8d7e9"))
	_draw_setting_slider(Vector2(525, 350), music_volume, settings_hover_index == 1)
	draw_string(ThemeDB.fallback_font, Vector2(875, 354), "%d%%" % int(music_volume * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, 35, 11, Color("#e7faff"))
	draw_string(ThemeDB.fallback_font, Vector2(295, 412), "SFX LEVEL", HORIZONTAL_ALIGNMENT_LEFT, 200, 12, Color("#b8d7e9"))
	_draw_setting_slider(Vector2(525, 425), sfx_volume, settings_hover_index == 2)
	draw_string(ThemeDB.fallback_font, Vector2(875, 429), "%d%%" % int(sfx_volume * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, 35, 11, Color("#e7faff"))
	# Display card
	var display_card := Rect2(270, 480, 740, 62)
	draw_rect(display_card, Color(0.018, 0.055, 0.078, 0.94))
	_draw_closed_outline(_beveled_points(display_card, 8.0), Color(0.12, 0.52, 0.65, 0.75), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(295, 505), "02  /  DISPLAY MODE", HORIZONTAL_ALIGNMENT_LEFT, 300, 13, Color("#b8d7e9"))
	var full_rect := Rect2(790, 489, 120, 44)
	var full_points: PackedVector2Array = _beveled_points(full_rect, 7.0)
	draw_colored_polygon(full_points, Color(0.02, 0.26, 0.34, 1.0) if settings_hover_index == 3 else Color(0.04, 0.10, 0.13, 1.0))
	_draw_closed_outline(full_points, Color("#63efff") if settings_hover_index == 3 else Color("#387f92"), 1.2)
	var full_label: String = "FULLSCREEN" if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else "WINDOWED"
	draw_string(ThemeDB.fallback_font, Vector2(full_rect.position.x - 4, full_rect.position.y + 27), full_label, HORIZONTAL_ALIGNMENT_CENTER, full_rect.size.x + 8, 10, Color("#eafaff"))
	# Back button
	var back_rect := Rect2(500, 565, 280, 48)
	var back_points: PackedVector2Array = _beveled_points(back_rect, 8.0)
	draw_colored_polygon(back_points, Color(0.02, 0.26, 0.34, 1.0) if settings_hover_index == 4 else Color(0.035, 0.09, 0.12, 1.0))
	_draw_closed_outline(back_points, Color("#63efff"), 1.4)
	draw_string(ThemeDB.fallback_font, Vector2(back_rect.position.x, back_rect.position.y + 29), "BACK TO MENU", HORIZONTAL_ALIGNMENT_CENTER, back_rect.size.x, 13, Color("#f1fdff"))

func _draw_setting_slider(start: Vector2, value: float, hovered: bool) -> void:
	var track: Rect2 = Rect2(start.x, start.y - 2.0, 335.0, 5.0)
	draw_rect(track, Color(0.08, 0.18, 0.23, 1.0))
	draw_rect(Rect2(track.position, Vector2(track.size.x * value, track.size.y)), Color("#45eaff") if hovered else Color("#22bcd4"))
	var knob_x: float = start.x + 335.0 * value
	draw_circle(Vector2(knob_x, start.y), 8.0 if hovered else 6.0, Color("#ff5573") if hovered else Color("#d9fbff"))
	draw_circle(Vector2(knob_x, start.y), 3.0, Color("#102d3a"))

func _draw_credits() -> void:
	_draw_story_page(true)

func _draw_overlay(title: String, subtitle: String) -> void:
	draw_rect(Rect2(0,0,1280,720), Color(0.01,0.015,0.03,0.82))
	draw_string(ThemeDB.fallback_font, Vector2(0,300), title, HORIZONTAL_ALIGNMENT_CENTER, 1280, 38, Color("#5deaff") if game_state != "game_over" else Color("#ff3158"))
	draw_string(ThemeDB.fallback_font, Vector2(0,345), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 1280, 17, Color("#b6c9d4"))
	draw_rect(Rect2(500,430,280,48), Color("#102e3b"))
	draw_rect(Rect2(500,430,280,48), Color("#48e8ff"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(500,460), ("CONTINUE TO LEVEL 2" if game_state == "victory" and level_index == 0 else ("PLAY AGAIN" if game_state == "victory" else ("RETRY FROM CHECKPOINT" if checkpoint_level == 1 else "RETRY RUN"))), HORIZONTAL_ALIGNMENT_CENTER, 280, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(0,525), "HOME", HORIZONTAL_ALIGNMENT_CENTER, 1280, 16, Color("#a9c2d0"))

func _draw_algorithm_panel() -> void:
	draw_rect(Rect2(20,100,310,270), Color(0.015,0.025,0.04,0.96))
	draw_rect(Rect2(20,100,310,270), Color("#45eaff"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(36,128), "CGG ALGORITHM LAB", HORIZONTAL_ALIGNMENT_LEFT, 280, 16, Color("#55eaff"))
	draw_string(ThemeDB.fallback_font, Vector2(36,158), "DDA / Bresenham: laser trace", HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(36,180), "Midpoint circle: nova outline", HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(36,202), "2D transforms: movement/aim", HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(36,224), "Cohen-Sutherland: clip demo", HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color.WHITE)
	var a := Vector2(48,265)
	var b := Vector2(295,280)
	for p in CG.dda_points(a, b):
		draw_rect(Rect2(Vector2(p),Vector2(2,2)),Color("#57f3ff"))
	var c := Vector2i(48,300)
	var d := Vector2i(295,330)
	for p in CG.bresenham_points(c, d):
		draw_rect(Rect2(Vector2(p),Vector2(2,2)),Color("#8bffb2"))
	for p in CG.midpoint_circle_points(Vector2i(170,310),24):
		draw_rect(Rect2(Vector2(p),Vector2(2,2)),Color(1.0,0.25,0.45,0.75))
	var clip_rect := Rect2(50,330,240,25)
	draw_rect(clip_rect, Color("#d858ff"), false, 1.0)
	var clipped := CG.clip_line(Vector2(35,345), Vector2(315,365), clip_rect)
	if clipped[0]:
		draw_line(clipped[1], clipped[2], Color("#ffffff"), 2.0)
	var fill_poly: Array[Vector2i] = [Vector2i(50,365),Vector2i(80,360),Vector2i(90,380),Vector2i(55,380)]
	for p in CG.scanline_fill_points(fill_poly):
		draw_rect(Rect2(Vector2(p),Vector2(1,1)),Color("#d858ff"))
	draw_string(ThemeDB.fallback_font, Vector2(36,400), "TAB: hide diagnostics", HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color("#9bb6c5"))

func draw_custom_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)

func draw_diamond(center: Vector2, radius: float, color: Color) -> void:
	var pts := PackedVector2Array([center+Vector2(0,-radius),center+Vector2(radius,0),center+Vector2(0,radius),center+Vector2(-radius,0)])
	draw_colored_polygon(pts,color)
