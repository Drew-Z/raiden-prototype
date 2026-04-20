extends Node

const MENU_SCENE := "res://scenes/ui/MainMenu.tscn"
const GAME_SCENE := "res://scenes/game/Game.tscn"
const RESULTS_SCENE := "res://scenes/ui/ResultsScreen.tscn"
const CHAPTER_BRIEFING_SCENE := "res://scenes/ui/ChapterBriefing.tscn"
const CHAPTER_ENDING_SCENE := "res://scenes/ui/ChapterEnding.tscn"
const CHAPTER_OUTRO_SCENE := "res://scenes/ui/ChapterOutro.tscn"
const SETTINGS_PATH := "user://settings.cfg"
const StageCatalogScript := preload("res://scripts/game/stage_catalog.gd")

var current_run: Dictionary = {}
var chapter_state: Dictionary = {}
var rng := RandomNumberGenerator.new()
var selected_stage_id := "stage_1"
var language_code := "zh_CN"


func _ready() -> void:
	rng.randomize()
	_load_settings()
	_ensure_input_actions()
	_reset_chapter_state()
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


func _reset_chapter_state() -> void:
	chapter_state = {
		"active": false,
		"chapter_finished": false,
		"chapter_victory": false,
		"stage_order": [],
		"current_index": 0,
		"stage_results": [],
		"total_score": 0,
		"total_time": 0.0,
		"total_spawned": 0,
		"total_destroyed": 0,
		"highest_fire": 1,
		"total_bombs_used": 0,
		"stage_start_state": {
			"lives": 3,
			"bombs": 2,
			"fire_level": 1
		},
		"next_stage_start_state": {
			"lives": 3,
			"bombs": 2,
			"fire_level": 1
		}
	}


func _get_default_start_state() -> Dictionary:
	var stage_meta := StageCatalogScript.get_stage_meta(selected_stage_id)
	if stage_meta.has("standalone_start_state"):
		return stage_meta.get("standalone_start_state", {
			"lives": 3,
			"bombs": 2,
			"fire_level": 1
		})
	return {
		"lives": 3,
		"bombs": 2,
		"fire_level": 1
	}


func _get_stage_start_state_internal() -> Dictionary:
	if is_chapter_mode():
		return chapter_state.get("stage_start_state", _get_default_start_state())
	return _get_default_start_state()


func reset_run() -> void:
	var stage_meta := StageCatalogScript.get_stage_meta(selected_stage_id)
	var start_state := _get_stage_start_state_internal()
	var start_fire_level := clampi(int(start_state.get("fire_level", 1)), 1, 5)
	current_run = {
		"stage_id": selected_stage_id,
		"stage_name": stage_meta.get("name", "STAGE 01 // SCRAMBLE"),
		"score": 0,
		"score_before_bonus": 0,
		"final_score": 0,
		"clear_bonus": 0,
		"survival_bonus": 0,
		"bomb_stock_bonus": 0,
		"efficiency_bonus": 0,
		"enemies_spawned": 0,
		"enemies_destroyed": 0,
		"fire_level": start_fire_level,
		"max_fire_level": start_fire_level,
		"bombs_used": 0,
		"bombs_collected": 0,
		"upgrades_collected": 0,
		"fire_route": [start_fire_level],
		"victory": false,
		"boss_defeated": false,
		"duration_sec": 0.0,
		"player_lives": int(start_state.get("lives", 3)),
		"player_bombs": int(start_state.get("bombs", 2)),
		"start_lives": int(start_state.get("lives", 3)),
		"start_bombs": int(start_state.get("bombs", 2)),
		"start_fire_level": start_fire_level,
		"chapter_transition_available": false
	}


func start_game(stage_id: String = "") -> void:
	if stage_id != "":
		selected_stage_id = stage_id
	_reset_chapter_state()
	reset_run()
	call_deferred("_change_scene", GAME_SCENE)


func start_chapter() -> void:
	_reset_chapter_state()
	chapter_state.active = true
	chapter_state.stage_order = StageCatalogScript.get_stage_order()
	chapter_state.current_index = 0
	chapter_state.stage_start_state = _get_default_start_state()
	chapter_state.next_stage_start_state = _get_default_start_state()
	selected_stage_id = chapter_state.stage_order[0]
	reset_run()
	call_deferred("_change_scene", GAME_SCENE)


func retry_run() -> void:
	reset_run()
	call_deferred("_change_scene", GAME_SCENE)


func start_next_chapter_stage() -> void:
	if not has_next_chapter_stage():
		return
	chapter_state.current_index = int(chapter_state.current_index) + 1
	chapter_state.stage_start_state = chapter_state.get("next_stage_start_state", _get_default_start_state())
	selected_stage_id = chapter_state.stage_order[chapter_state.current_index]
	reset_run()
	call_deferred("_change_scene", GAME_SCENE)


func show_results() -> void:
	call_deferred("_change_scene", RESULTS_SCENE)


func show_chapter_briefing() -> void:
	call_deferred("_change_scene", CHAPTER_BRIEFING_SCENE)


func show_chapter_ending() -> void:
	call_deferred("_change_scene", CHAPTER_ENDING_SCENE)


func show_chapter_outro() -> void:
	call_deferred("_change_scene", CHAPTER_OUTRO_SCENE)


func go_to_menu() -> void:
	call_deferred("_change_scene", MENU_SCENE)


func get_selected_stage_id() -> String:
	return selected_stage_id


func get_selected_stage_meta() -> Dictionary:
	return StageCatalogScript.get_stage_meta(selected_stage_id)


func get_stage_start_state() -> Dictionary:
	return _get_stage_start_state_internal().duplicate(true)


func is_chapter_mode() -> bool:
	return bool(chapter_state.get("active", false))


func has_next_chapter_stage() -> bool:
	if not is_chapter_mode():
		return false
	return int(chapter_state.get("current_index", 0)) < chapter_state.get("stage_order", []).size() - 1


func is_chapter_transition_pending() -> bool:
	return bool(current_run.get("chapter_transition_available", false))


func is_chapter_complete() -> bool:
	return is_chapter_mode() and bool(chapter_state.get("chapter_finished", false)) and bool(chapter_state.get("chapter_victory", false))


func get_next_stage_meta() -> Dictionary:
	if not has_next_chapter_stage():
		return {}
	var next_stage_id: String = String(chapter_state.stage_order[int(chapter_state.current_index) + 1])
	return StageCatalogScript.get_stage_meta(next_stage_id)


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
	current_run.chapter_transition_available = false

	if is_chapter_mode():
		_record_chapter_result()
		if victory and has_next_chapter_stage():
			chapter_state.next_stage_start_state = _build_next_carry_state()
			current_run.chapter_transition_available = true
		else:
			chapter_state.chapter_finished = true
			chapter_state.chapter_victory = victory and not has_next_chapter_stage()

	print("RUN_RESULT victory=%s score=%d kill_rate=%.2f max_fire=%d route=%s bombs_used=%d lives=%d" % [
		str(victory),
		int(current_run.final_score),
		get_kill_rate(),
		int(current_run.max_fire_level),
		get_fire_route_text(),
		int(current_run.bombs_used),
		int(current_run.player_lives)
	])
	if is_chapter_mode() and bool(chapter_state.get("chapter_finished", false)):
		print("CHAPTER_RESULT victory=%s total_score=%d kill_rate=%.2f stages=%d highest_fire=%d" % [
			str(bool(chapter_state.get("chapter_victory", false))),
			int(chapter_state.get("total_score", 0)),
			get_chapter_kill_rate(),
			int(chapter_state.get("stage_results", []).size()),
			int(chapter_state.get("highest_fire", 1))
		])
	show_results()


func _record_chapter_result() -> void:
	var stage_result := {
		"stage_id": current_run.stage_id,
		"stage_name": current_run.stage_name,
		"final_score": current_run.final_score,
		"kill_rate": get_kill_rate(),
		"max_fire_level": current_run.max_fire_level,
		"bombs_used": current_run.bombs_used,
		"player_lives": current_run.player_lives,
		"duration_sec": current_run.duration_sec,
		"victory": current_run.victory,
		"fire_route": get_fire_route_text(),
		"grade": get_performance_grade()
	}
	var stage_results: Array = chapter_state.get("stage_results", [])
	stage_results.append(stage_result)
	chapter_state.stage_results = stage_results
	chapter_state.total_score = int(chapter_state.get("total_score", 0)) + int(current_run.final_score)
	chapter_state.total_time = float(chapter_state.get("total_time", 0.0)) + float(current_run.duration_sec)
	chapter_state.total_spawned = int(chapter_state.get("total_spawned", 0)) + int(current_run.enemies_spawned)
	chapter_state.total_destroyed = int(chapter_state.get("total_destroyed", 0)) + int(current_run.enemies_destroyed)
	chapter_state.highest_fire = max(int(chapter_state.get("highest_fire", 1)), int(current_run.max_fire_level))
	chapter_state.total_bombs_used = int(chapter_state.get("total_bombs_used", 0)) + int(current_run.bombs_used)


func _build_next_carry_state() -> Dictionary:
	return {
		"lives": max(1, int(current_run.player_lives)),
		"bombs": clampi(max(int(current_run.player_bombs), 1) + 1, 1, 4),
		"fire_level": clampi(max(int(current_run.fire_level), 3), 1, 5)
	}


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


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		language_code = "zh_CN"
		return
	language_code = String(config.get_value("general", "language", "zh_CN"))
	if language_code not in ["zh_CN", "en"]:
		language_code = "zh_CN"


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("general", "language", language_code)
	config.save(SETTINGS_PATH)


func get_language_code() -> String:
	return language_code


func is_english() -> bool:
	return language_code == "en"


func set_language_code(next_language_code: String) -> void:
	if next_language_code not in ["zh_CN", "en"]:
		return
	if language_code == next_language_code:
		return
	language_code = next_language_code
	_save_settings()


func _lang(zh_text: String, en_text: String) -> String:
	return en_text if is_english() else zh_text


func get_kill_rate() -> float:
	if current_run.enemies_spawned <= 0:
		return 0.0
	return float(current_run.enemies_destroyed) / float(current_run.enemies_spawned) * 100.0


func get_chapter_kill_rate() -> float:
	if int(chapter_state.get("total_spawned", 0)) <= 0:
		return 0.0
	return float(chapter_state.get("total_destroyed", 0)) / float(chapter_state.get("total_spawned", 0)) * 100.0


func get_fire_route_text() -> String:
	var parts: Array[String] = []
	for value in current_run.fire_route:
		parts.append("Lv%d" % int(value))
	return " -> ".join(parts)


func get_lives_lost() -> int:
	return max(0, int(current_run.start_lives) - int(current_run.player_lives))


func get_result_title() -> String:
	if is_chapter_transition_pending():
		return _lang("%s 通关" % String(current_run.stage_name), "%s CLEAR" % String(current_run.stage_name))
	if is_chapter_complete():
		return _lang("章节完成", "CHAPTER CLEAR")
	if is_chapter_mode() and not current_run.victory:
		return _lang("章节失败", "CHAPTER FAILED")
	return _lang("%s 通关" % String(current_run.stage_name), "%s CLEAR" % String(current_run.stage_name)) if current_run.victory else _lang("任务失败", "MISSION FAILED")


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
	if get_lives_lost() == 0:
		points += 2
	elif get_lives_lost() <= 1:
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
	if is_chapter_transition_pending():
		var next_meta := get_next_stage_meta()
		return "%s secured. Route carries forward into %s with retained resources." % [
			String(current_run.stage_name),
			String(next_meta.get("menu_label", "next stage"))
		]
	if is_chapter_complete():
		return "Two-stage chapter secured. Growth, bomb routing and boss control all held across the full chain."
	if is_chapter_mode() and not current_run.victory:
		return "Chapter pressure broke the route. The handoff into the next segment still needs a safer resource plan."
	if current_run.victory and get_lives_lost() == 0 and current_run.max_fire_level >= 5:
		return "%s secured with strong tempo and resource control." % String(current_run.stage_name)
	if current_run.victory:
		return "%s secured. Pressure curve held to the end." % String(current_run.stage_name)
	if current_run.max_fire_level >= 4:
		return "Good growth, but the late pressure still broke the run."
	return "Early survival is stable, but growth and routing need work."


func get_score_breakdown_text() -> String:
	if not current_run.victory:
		return _lang("战斗得分：%06d", "Battle Score: %06d") % int(current_run.final_score)
	if is_english():
		return "Battle: %06d\nClear Bonus: %04d\nSurvival Bonus: %04d\nBomb Stock Bonus: %04d\nEfficiency Bonus: %04d\nFinal Score: %06d" % [
			int(current_run.score_before_bonus),
			int(current_run.clear_bonus),
			int(current_run.survival_bonus),
			int(current_run.bomb_stock_bonus),
			int(current_run.efficiency_bonus),
			int(current_run.final_score)
		]
	return "战斗分：%06d\n通关奖励：%04d\n生存奖励：%04d\n炸弹库存奖励：%04d\n效率奖励：%04d\n最终分数：%06d" % [
		int(current_run.score_before_bonus),
		int(current_run.clear_bonus),
		int(current_run.survival_bonus),
		int(current_run.bomb_stock_bonus),
		int(current_run.efficiency_bonus),
		int(current_run.final_score)
	]


func get_result_tags() -> Array[String]:
	var tags: Array[String] = []
	if is_chapter_transition_pending():
		tags.append("STAGE ADVANCE")
	if is_chapter_complete():
		tags.append("CHAPTER CLEAR")
		tags.append("CHAPTER %s" % get_chapter_grade())
	if current_run.victory:
		tags.append("CLEAR")
	if get_kill_rate() >= 85.0:
		tags.append("HIGH KILL")
	if current_run.max_fire_level >= 5:
		tags.append("MAX FIRE")
	if get_lives_lost() == 0:
		tags.append("NO MISS")
	if current_run.bombs_used >= 2:
		tags.append("BOMB ROUTE")
	if tags.is_empty():
		tags.append("IN PROGRESS")
	return tags


func get_chapter_grade() -> String:
	if not is_chapter_mode():
		return get_performance_grade()
	var points := 0
	if bool(chapter_state.get("chapter_victory", false)):
		points += 3
	if get_chapter_kill_rate() >= 90.0:
		points += 2
	elif get_chapter_kill_rate() >= 82.0:
		points += 1
	if int(chapter_state.get("highest_fire", 1)) >= 5:
		points += 2
	if int(chapter_state.get("total_bombs_used", 0)) <= 3:
		points += 1
	if int(current_run.get("player_lives", 0)) >= 1:
		points += 1
	if points >= 8:
		return "S"
	if points >= 6:
		return "A"
	if points >= 4:
		return "B"
	return "C"


func get_next_focus() -> String:
	if is_chapter_transition_pending():
		var carry_state: Dictionary = chapter_state.get("next_stage_start_state", _get_default_start_state())
		return "Stage handoff locked. Next start state: Hull %d, Bomb %d, Fire Lv%d." % [
			int(carry_state.get("lives", 3)),
			int(carry_state.get("bombs", 2)),
			int(carry_state.get("fire_level", 1))
		]
	if is_chapter_complete():
		return "Chapter route is stable. The next gains come from cleaning Stage 02 kill pace, tightening suppressor routing and sharpening the final boss break."
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
	if is_chapter_complete():
		return "Chapter offense held together. Growth and stage handoff stayed online through both boss segments."
	if get_kill_rate() >= 85.0 and current_run.max_fire_level >= 5:
		return "Offense locked in. Fire route reached max output and held board control."
	if current_run.max_fire_level < 4:
		return "Fire growth came online too late. Early pickup routing still matters most."
	return "Damage pace is stable, but a few side waves are still slipping past the route."


func get_survival_summary() -> String:
	if get_lives_lost() == 0:
		return "Hull integrity held all the way through. Spacing and threat reads stayed clean."
	if current_run.victory:
		return "The run survived the peak, but late pressure still forced a recovery line."
	return "The route breaks under pressure. Re-enter boss space with wider safety margins."


func get_resource_summary() -> String:
	if is_chapter_transition_pending():
		return "Chapter carry-over is active. Stage clear granted a one-bomb resupply and preserved your fire route."
	if current_run.bombs_used >= 3:
		return "Bomb routing is active and intentional. Resources are being spent to hold tempo."
	if current_run.bombs_used <= 0 and current_run.victory:
		return "Bomb stock stayed untouched. There is room to convert resources into faster clears."
	return "Resource usage is conservative. The next gains come from cleaner bomb timing."


func get_chapter_progress_text() -> String:
	if not is_chapter_mode():
		return ""
	var current_stage_number: int = min(int(chapter_state.get("current_index", 0)) + 1, chapter_state.get("stage_order", []).size())
	return "Chapter Run %d / %d\nTotal Score %06d    Chapter Kill %.0f%%" % [
		current_stage_number,
		chapter_state.get("stage_order", []).size(),
		int(chapter_state.get("total_score", 0)),
		get_chapter_kill_rate()
	]


func get_chapter_stage_breakdown_text() -> String:
	if not is_chapter_mode():
		return ""
	var lines: Array[String] = []
	var stage_results: Array = chapter_state.get("stage_results", [])
	for stage_result in stage_results:
		lines.append("%s  %s  GRADE %s  %06d  Kill %.0f%%  Fire Lv%d" % [
			String(stage_result.get("stage_name", "")),
			"CLEAR" if bool(stage_result.get("victory", false)) else "FAIL",
			String(stage_result.get("grade", "C")),
			int(stage_result.get("final_score", 0)),
			float(stage_result.get("kill_rate", 0.0)),
			int(stage_result.get("max_fire_level", 1))
		])
	if lines.is_empty():
		lines.append("Chapter route not started yet.")
	return "\n".join(lines)


func get_chapter_timeline() -> Array[Dictionary]:
	var cards: Array[Dictionary] = []
	if not is_chapter_mode():
		return cards
	var stage_results: Array = chapter_state.get("stage_results", [])
	for stage_index in range(chapter_state.get("stage_order", []).size()):
		var stage_id := String(chapter_state.stage_order[stage_index])
		var meta := StageCatalogScript.get_stage_meta(stage_id)
		var result: Dictionary = {}
		if stage_index < stage_results.size():
			result = stage_results[stage_index]
		cards.append({
			"label": meta.get("menu_label", stage_id),
			"name": meta.get("name", stage_id),
			"summary": meta.get("summary", ""),
			"completed": stage_index < stage_results.size(),
			"victory": bool(result.get("victory", false)),
			"grade": String(result.get("grade", "--")),
			"active": stage_index == int(chapter_state.get("current_index", 0)) and not bool(chapter_state.get("chapter_finished", false)),
			"pending": stage_index >= stage_results.size()
		})
	return cards


func get_chapter_carry_summary() -> String:
	if not is_chapter_transition_pending():
		return ""
	var carry_state: Dictionary = chapter_state.get("next_stage_start_state", _get_default_start_state())
	return "Carry Loadout\nHull %d    Bomb %d    Fire Lv%d" % [
		int(carry_state.get("lives", 3)),
		int(carry_state.get("bombs", 2)),
		int(carry_state.get("fire_level", 1))
	]


func get_chapter_transition_brief() -> String:
	if not is_chapter_transition_pending():
		return ""
	var next_meta := get_next_stage_meta()
	return "%s\n%s" % [
		String(next_meta.get("tagline", "Next stage incoming.")),
		String(next_meta.get("summary", ""))
	]


func get_chapter_clear_summary() -> String:
	if not is_chapter_complete():
		return ""
	return "Two-stage route secured with grade %s, %06d total score, %.0f%% chapter kill and Lv%d peak fire." % [
		get_chapter_grade(),
		int(chapter_state.get("total_score", 0)),
		get_chapter_kill_rate(),
		int(chapter_state.get("highest_fire", 1))
	]


func get_chapter_epilogue() -> String:
	if not is_chapter_complete():
		return ""
	return "Scramble opened the route, Storm Front closed it. The current build now reads like a full showcase sortie rather than a disconnected test run."


func get_chapter_outro_headline() -> String:
	if not is_chapter_complete():
		return ""
	var chapter_grade := get_chapter_grade()
	if chapter_grade == "S":
		return "Route dominance confirmed. The full chapter now reads like a showcase strike package."
	if chapter_grade == "A":
		return "Chapter route secured with strong control. The build is now presentation-ready across both legs."
	return "Chapter secured. The route is stable, with room to sharpen pacing and finale pressure."


func get_chapter_outro_directive() -> String:
	if not is_chapter_complete():
		return ""
	return "Next directive: reinforce Stage 02 spectacle, deepen storm hazard interplay and convert this chapter flow into a true vertical-slice finish."


func get_chapter_ending_banner() -> String:
	if not is_chapter_complete():
		return ""
	return "ENDING // ROUTE VERIFIED"


func get_chapter_ending_title() -> String:
	if not is_chapter_complete():
		return ""
	return "CHAPTER ROUTE LOCKED"


func get_chapter_ending_summary() -> String:
	if not is_chapter_complete():
		return ""
	return "%s\n%s" % [
		get_chapter_clear_summary(),
		get_chapter_outro_headline()
	]


func get_chapter_ending_verdict() -> String:
	if not is_chapter_complete():
		return ""
	var chapter_grade := get_chapter_grade()
	if chapter_grade == "S":
		return "Vertical slice candidate confirmed. The dual-stage route now holds up as a showcase build."
	if chapter_grade == "A":
		return "Vertical slice candidate is stable. One more polish pass should be enough for a stronger review build."
	return "Route is working, but still needs one more polish pass before it fully reads like a finished slice."


func get_chapter_review_cards() -> Array[Dictionary]:
	var cards: Array[Dictionary] = []
	if not is_chapter_complete():
		return cards

	var chapter_kill := get_chapter_kill_rate()
	var chapter_grade := get_chapter_grade()
	var total_bombs := int(chapter_state.get("total_bombs_used", 0))

	cards.append({
		"title": "FLOW",
		"status": "LOCKED" if bool(chapter_state.get("chapter_victory", false)) else "UNSTABLE",
		"detail": "Two-stage route, carry state and endcap scenes now hold together as one complete chapter flow."
	})

	cards.append({
		"title": "PRESSURE",
		"status": "READY" if chapter_kill >= 90.0 and int(chapter_state.get("highest_fire", 1)) >= 5 else "TUNING",
		"detail": (
			"Stage 02 climax now lands as enemy, storm hazard and boss pressure converge into one readable finish."
			if chapter_kill >= 90.0
			else
			"Chapter pressure is stable, but kill pace and final routing still have room for one more polish pass."
		)
	})

	cards.append({
		"title": "REVIEW",
		"status": "BUILD READY" if chapter_grade in ["S", "A"] and total_bombs <= 5 else "POLISH",
		"detail": (
			"The current build reads like a vertical-slice candidate and is ready for external review framing."
			if chapter_grade in ["S", "A"] and total_bombs <= 5
			else
			"The route is presentable, but still benefits from one more round of pacing and presentation cleanup."
		)
	})

	return cards


func get_chapter_final_pass_title() -> String:
	if not is_chapter_complete():
		return ""
	var chapter_grade := get_chapter_grade()
	if chapter_grade == "S":
		return "FINAL PASS // REVIEW READY"
	if chapter_grade == "A":
		return "FINAL PASS // STRONG CANDIDATE"
	return "FINAL PASS // ONE MORE POLISH"


func get_chapter_final_pass_detail() -> String:
	if not is_chapter_complete():
		return ""
	var chapter_grade := get_chapter_grade()
	if chapter_grade == "S":
		return "This build is strong enough to present as a dual-stage vertical-slice candidate right now. Further work should focus on final packaging, not new systems."
	if chapter_grade == "A":
		return "The route is stable and presentation-ready in structure. One last polish pass on pacing and ending presentation should be enough for a stronger review build."
	return "The chapter already reads as one coherent slice, but it still benefits from another polish pass before it should be framed as a finished review build."


func get_build_badge() -> String:
	if is_chapter_complete():
		var chapter_grade := get_chapter_grade()
		if chapter_grade == "S":
			return _lang("当前构建 // 可评审", "BUILD STATUS // REVIEW READY")
		if chapter_grade == "A":
			return _lang("当前构建 // 强候选版", "BUILD STATUS // STRONG CANDIDATE")
	return _lang("当前构建 // 双关切片候选", "BUILD STATUS // DUAL-STAGE SLICE CANDIDATE")


func get_build_summary() -> String:
	if is_chapter_complete():
		return _lang(
			"当前版本已包含完整双关路线、继承交接、独立章节场景，以及一个可读的最终 Boss 收束。",
			"Current build includes a full two-stage route, carry-state handoff, independent chapter scenes and a readable final boss climax."
		)
	return _lang(
		"当前版本聚焦于一条经过打磨的双关展示路线，并带有章节交接、结尾与总结流程。",
		"Current build focuses on a polished two-stage showcase route with chapter handoff, ending and debrief flow."
	)


func get_final_package_summary() -> String:
	if not is_chapter_complete():
		return "Package target: finish a clean two-stage run, verify the chapter handoff and review the ending scenes as one connected presentation chain."
	return "Package target met: the current build now reads like a compact dual-stage vertical-slice candidate, with full chapter start, handoff, climax, ending and debrief flow."


func get_final_package_next_step() -> String:
	if not is_chapter_complete():
		return "Next step: clear the full chapter route and confirm the ending chain holds together under review conditions."
	var chapter_grade := get_chapter_grade()
	if chapter_grade == "S":
		return "Next step: freeze scope, clean presentation details and prepare a formal final summary for review."
	if chapter_grade == "A":
		return "Next step: run one more polish pass on pacing and ending presentation before freezing scope."
	return "Next step: keep scope frozen and spend one last pass on pacing cleanup before calling the slice review-ready."


func get_demo_route_summary() -> String:
	if is_chapter_complete():
		return _lang(
			"推荐演示路线\n章节连打 -> 简报 -> 第二关风暴高潮 -> 章节结尾 -> 章节总结",
			"Recommended Demo Route\nChapter Run -> Briefing -> Stage 02 storm climax -> ChapterEnding -> ChapterOutro"
		)
	return _lang(
		"推荐演示路线\n章节连打 -> 第一关成长 -> 简报 -> 第二关风暴 Boss -> 结尾 / 总结",
		"Recommended Demo Route\nChapter Run -> Stage 01 growth -> Briefing -> Stage 02 storm boss -> Ending / Debrief"
	)


func get_demo_checklist_text() -> String:
	if is_chapter_complete():
		return _lang(
			"演示检查表\n- 从章节连打开始\n- 在简报里展示继承状态\n- 打到第二关风暴 Boss 与最终破口\n- 让结尾与总结完整播放，作为最终包装",
			"Demo Checklist\n- Start from Chapter Run\n- Show carry-state handoff in Briefing\n- Reach Stage 02 storm boss and final breach\n- Let Ending and Debrief play through as final package"
		)
	return _lang(
		"演示检查表\n- 优先展示章节连打，而不是单关入口\n- 突出第一关成长与炸弹路线\n- 展示第二关风暴机关与 Boss 高潮\n- 最后落到结尾 / 总结，形成完整包装",
		"Demo Checklist\n- Prefer Chapter Run over single-stage entry\n- Highlight Stage 01 growth and bomb routing\n- Show Stage 02 storm hazards and boss climax\n- Finish on Ending / Debrief for the full package"
	)


func get_release_candidate_label() -> String:
	if is_chapter_complete():
		var chapter_grade := get_chapter_grade()
		if chapter_grade == "S":
			return _lang("当前 RC // 可评审", "CURRENT RC // REVIEW READY")
		if chapter_grade == "A":
			return _lang("当前 RC // 强候选版", "CURRENT RC // STRONG CANDIDATE")
	return _lang("当前 RC // 推荐章节连打", "CURRENT RC // CHAPTER RUN RECOMMENDED")


func get_chapter_transition_text() -> String:
	if not is_chapter_transition_pending():
		return ""
	var next_meta := get_next_stage_meta()
	var carry_state: Dictionary = chapter_state.get("next_stage_start_state", _get_default_start_state())
	return "Next: %s\nStart Hull %d    Start Bomb %d    Start Fire Lv%d" % [
		String(next_meta.get("name", "NEXT STAGE")),
		int(carry_state.get("lives", 3)),
		int(carry_state.get("bombs", 2)),
		int(carry_state.get("fire_level", 1))
	]


func is_autoplay() -> bool:
	return OS.get_cmdline_args().has("--autoplay") or OS.get_cmdline_user_args().has("--autoplay")


func wants_autoplay_chapter() -> bool:
	return OS.get_cmdline_args().has("--chapter") or OS.get_cmdline_user_args().has("--chapter")


func get_requested_autoplay_stage() -> String:
	var args := OS.get_cmdline_args()
	var user_args := OS.get_cmdline_user_args()
	if args.has("--stage2") or user_args.has("--stage2"):
		return "stage_2"
	return selected_stage_id
