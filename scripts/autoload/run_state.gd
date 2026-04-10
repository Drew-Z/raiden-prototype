extends Node

const MENU_SCENE := "res://scenes/ui/MainMenu.tscn"
const GAME_SCENE := "res://scenes/game/Game.tscn"
const RESULTS_SCENE := "res://scenes/ui/ResultsScreen.tscn"

var current_run: Dictionary = {}
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	_ensure_input_actions()
	reset_run()


func _ensure_input_actions() -> void:
	_register_keys("move_left", [KEY_LEFT, KEY_A])
	_register_keys("move_right", [KEY_RIGHT, KEY_D])
	_register_keys("move_up", [KEY_UP, KEY_W])
	_register_keys("move_down", [KEY_DOWN, KEY_S])
	_register_keys("bomb", [KEY_SPACE, KEY_SHIFT, KEY_X])
	_register_keys("ui_accept", [KEY_ENTER, KEY_KP_ENTER, KEY_Z])
	_register_keys("ui_cancel", [KEY_ESCAPE])


func _register_keys(action_name: String, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var existing_events := InputMap.action_get_events(action_name)
	for keycode in keycodes:
		var found := false
		for event in existing_events:
			if event is InputEventKey and event.physical_keycode == keycode:
				found = true
				break
		if found:
			continue

		var input_event := InputEventKey.new()
		input_event.physical_keycode = keycode
		InputMap.action_add_event(action_name, input_event)


func reset_run() -> void:
	current_run = {
		"score": 0,
		"enemies_spawned": 0,
		"enemies_destroyed": 0,
		"fire_level": 1,
		"max_fire_level": 1,
		"bombs_used": 0,
		"upgrades_collected": 0,
		"fire_route": [1],
		"victory": false,
		"boss_defeated": false,
		"duration_sec": 0.0,
		"player_lives": 3,
		"player_bombs": 2
	}


func start_game() -> void:
	reset_run()
	call_deferred("_change_scene", GAME_SCENE)


func show_results() -> void:
	call_deferred("_change_scene", RESULTS_SCENE)


func go_to_menu() -> void:
	call_deferred("_change_scene", MENU_SCENE)


func register_enemy_spawn() -> void:
	current_run.enemies_spawned += 1


func register_enemy_destroyed(score_value: int, is_boss: bool) -> void:
	current_run.enemies_destroyed += 1
	current_run.score += score_value
	if is_boss:
		current_run.boss_defeated = true


func add_score(amount: int) -> void:
	current_run.score += amount


func register_fire_level(level: int) -> void:
	current_run.fire_level = level
	current_run.max_fire_level = max(current_run.max_fire_level, level)
	var route: Array = current_run.fire_route
	if route.is_empty() or route.back() != level:
		route.append(level)
	current_run.fire_route = route


func register_upgrade_pickup() -> void:
	current_run.upgrades_collected += 1


func register_bomb_used() -> void:
	current_run.bombs_used += 1


func update_player_state(lives: int, bombs: int, fire_level: int) -> void:
	current_run.player_lives = lives
	current_run.player_bombs = bombs
	register_fire_level(fire_level)


func finish_run(victory: bool, duration_sec: float) -> void:
	current_run.victory = victory
	current_run.duration_sec = duration_sec
	print("RUN_RESULT victory=%s score=%d kill_rate=%.2f max_fire=%d route=%s bombs_used=%d lives=%d" % [
		str(victory),
		int(current_run.score),
		get_kill_rate(),
		int(current_run.max_fire_level),
		get_fire_route_text(),
		int(current_run.bombs_used),
		int(current_run.player_lives)
	])
	show_results()


func _change_scene(scene_path: String) -> void:
	if get_tree():
		get_tree().change_scene_to_file(scene_path)


func get_kill_rate() -> float:
	if current_run.enemies_spawned <= 0:
		return 0.0
	return float(current_run.enemies_destroyed) / float(current_run.enemies_spawned) * 100.0


func get_fire_route_text() -> String:
	var parts: Array[String] = []
	for value in current_run.fire_route:
		parts.append("Lv%d" % int(value))
	return " -> ".join(parts)


func is_autoplay() -> bool:
	return OS.get_cmdline_args().has("--autoplay") or OS.get_cmdline_user_args().has("--autoplay")
