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
	_register_keys("pause_game", [KEY_ESCAPE, KEY_P])
	_register_keys("restart_game", [KEY_R])
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
		"score_before_bonus": 0,
		"final_score": 0,
		"clear_bonus": 0,
		"survival_bonus": 0,
		"bomb_stock_bonus": 0,
		"efficiency_bonus": 0,
		"enemies_spawned": 0,
		"enemies_destroyed": 0,
		"fire_level": 1,
		"max_fire_level": 1,
		"bombs_used": 0,
		"bombs_collected": 0,
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


func register_bomb_pickup() -> void:
	current_run.bombs_collected += 1


func update_player_state(lives: int, bombs: int, fire_level: int) -> void:
	current_run.player_lives = lives
	current_run.player_bombs = bombs
	register_fire_level(fire_level)


func finish_run(victory: bool, duration_sec: float) -> void:
	current_run.victory = victory
	current_run.duration_sec = duration_sec
	current_run.score_before_bonus = current_run.score
	_apply_end_bonuses()
	current_run.final_score = current_run.score
	print("RUN_RESULT victory=%s score=%d kill_rate=%.2f max_fire=%d route=%s bombs_used=%d lives=%d" % [
		str(victory),
		int(current_run.final_score),
		get_kill_rate(),
		int(current_run.max_fire_level),
		get_fire_route_text(),
		int(current_run.bombs_used),
		int(current_run.player_lives)
	])
	show_results()


func _apply_end_bonuses() -> void:
	current_run.clear_bonus = 0
	current_run.survival_bonus = 0
	current_run.bomb_stock_bonus = 0
	current_run.efficiency_bonus = 0
	if not current_run.victory:
		return

	current_run.clear_bonus = 2000
	current_run.survival_bonus = int(current_run.player_lives) * 500
	current_run.bomb_stock_bonus = int(current_run.player_bombs) * 250

	var kill_rate := get_kill_rate()
	if kill_rate >= 90.0:
		current_run.efficiency_bonus = 1200
	elif kill_rate >= 80.0:
		current_run.efficiency_bonus = 800
	elif kill_rate >= 70.0:
		current_run.efficiency_bonus = 400

	current_run.score += current_run.clear_bonus
	current_run.score += current_run.survival_bonus
	current_run.score += current_run.bomb_stock_bonus
	current_run.score += current_run.efficiency_bonus


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


func get_lives_lost() -> int:
	return max(0, 3 - int(current_run.player_lives))


func get_performance_grade() -> String:
	var points := 0
	if current_run.victory:
		points += 2
	if get_kill_rate() >= 85.0:
		points += 2
	elif get_kill_rate() >= 68.0:
		points += 1
	if current_run.max_fire_level >= 5:
		points += 2
	elif current_run.max_fire_level >= 4:
		points += 1
	if current_run.player_lives >= 3:
		points += 2
	elif current_run.player_lives >= 2:
		points += 1
	if current_run.bombs_used <= 1:
		points += 1

	if points >= 8:
		return "S"
	if points >= 6:
		return "A"
	if points >= 4:
		return "B"
	return "C"


func get_result_flavor() -> String:
	if current_run.victory and current_run.player_lives >= 3 and current_run.max_fire_level >= 5:
		return "High tempo clear with strong resource control."
	if current_run.victory:
		return "Stage secured. Pressure curve held to the end."
	if current_run.max_fire_level >= 4:
		return "Good growth, but the late pressure still broke the run."
	return "Early survival is stable, but growth and routing need work."


func get_score_breakdown_text() -> String:
	if not current_run.victory:
		return "Battle Score: %06d" % int(current_run.final_score)
	return "Battle: %06d\nClear Bonus: %04d\nSurvival Bonus: %04d\nBomb Stock Bonus: %04d\nEfficiency Bonus: %04d\nFinal Score: %06d" % [
		int(current_run.score_before_bonus),
		int(current_run.clear_bonus),
		int(current_run.survival_bonus),
		int(current_run.bomb_stock_bonus),
		int(current_run.efficiency_bonus),
		int(current_run.final_score)
	]


func get_result_tags() -> Array[String]:
	var tags: Array[String] = []
	if current_run.victory:
		tags.append("CLEAR")
	if get_kill_rate() >= 85.0:
		tags.append("HIGH KILL")
	if current_run.max_fire_level >= 5:
		tags.append("MAX FIRE")
	if current_run.player_lives >= 3:
		tags.append("NO MISS")
	if current_run.bombs_used >= 2:
		tags.append("BOMB ROUTE")
	if tags.is_empty():
		tags.append("IN PROGRESS")
	return tags


func get_next_focus() -> String:
	if not current_run.victory:
		if current_run.max_fire_level < 4:
			return "Prioritize early power pickups to hit Lv4 before the final push."
		return "Hold one bomb for the boss transition and re-enter with stable spacing."
	if get_kill_rate() < 80.0:
		return "You can route more side formations for a stronger kill rate."
	if current_run.bombs_used == 0:
		return "Try cashing one bomb during peak pressure for a faster boss break."
	return "The core loop is stable. Next gains come from cleaner routing and efficiency."


func get_offense_summary() -> String:
	if get_kill_rate() >= 85.0 and current_run.max_fire_level >= 5:
		return "Offense locked in. Fire route reached max output and held board control."
	if current_run.max_fire_level < 4:
		return "Fire growth came online too late. Early pickup routing still matters most."
	return "Damage pace is stable, but a few side waves are still slipping past the route."


func get_survival_summary() -> String:
	if current_run.player_lives >= 3:
		return "Hull integrity held all the way through. Spacing and threat reads stayed clean."
	if current_run.victory:
		return "The run survived the peak, but late pressure still forced a recovery line."
	return "The route breaks under pressure. Re-enter boss space with wider safety margins."


func get_resource_summary() -> String:
	if current_run.bombs_used >= 3:
		return "Bomb routing is active and intentional. Resources are being spent to hold tempo."
	if current_run.bombs_used <= 0 and current_run.victory:
		return "Bomb stock stayed untouched. There is room to convert resources into faster clears."
	return "Resource usage is conservative. The next gains come from cleaner bomb timing."


func is_autoplay() -> bool:
	return OS.get_cmdline_args().has("--autoplay") or OS.get_cmdline_user_args().has("--autoplay")
