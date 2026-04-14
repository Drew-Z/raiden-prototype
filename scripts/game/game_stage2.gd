extends Node2D

const PlayerScript := preload("res://scripts/entities/player.gd")
const EnemyScript := preload("res://scripts/entities/enemy.gd")
const PickupScript := preload("res://scripts/entities/pickup.gd")
const StarfieldScript := preload("res://scripts/game/starfield.gd")
const HUDScript := preload("res://scripts/ui/hud_v2.gd")
const StageCatalogScript := preload("res://scripts/game/stage_catalog.gd")
const BombEffectScript := preload("res://scripts/game/bomb_effect.gd")
const ImpactEffectScript := preload("res://scripts/game/impact_effect.gd")
const ExplosionEffectScript := preload("res://scripts/game/explosion_effect.gd")
const BossIntroEffectScript := preload("res://scripts/game/boss_intro_effect.gd")
const BossBreakEffectScript := preload("res://scripts/game/boss_break_effect.gd")
const BgmControllerScript := preload("res://scripts/game/bgm_controller.gd")
const ScorePopupScript := preload("res://scripts/game/score_popup.gd")
const SfxControllerScript := preload("res://scripts/game/sfx_controller.gd")
const StormStrikeScript := preload("res://scripts/game/storm_strike.gd")
const StormSweepScript := preload("res://scripts/game/storm_sweep.gd")

var playfield_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var player
var hud
var world_layer: Node2D
var bullet_layer: Node2D
var enemy_layer: Node2D
var pickup_layer: Node2D
var effects_layer: Node2D
var hazard_layer: Node2D
var waves: Array[Dictionary] = []
var stage_events: Array[Dictionary] = []
var boss_config: Dictionary = {}
var stage_meta: Dictionary = {}
var wave_index := 0
var event_index := 0
var stage_time := 0.0
var run_finished := false
var boss_spawned := false
var active_boss
var drop_fail_streak := 0
var last_fire_level := 1
var last_bomb_count := 2
var boss_phase_seen := 1
var boss_overdrive_announced := false
var boss_final_warning_announced := false
var boss_finish_window_announced := false
var boss_phase_hazard_fired: Dictionary = {}
var shake_timer := 0.0
var shake_strength := 0.0
var time_stop_timer := 0.0
var time_stop_scale := 1.0
var sfx
var bgm


func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_stage()
	_build_scene()

	if RunState.is_chapter_mode():
		var stage_order := StageCatalogScript.get_stage_order()
		var current_index := StageCatalogScript.get_stage_index(RunState.get_selected_stage_id()) + 1
		_queue_banner("CHAPTER RUN %d / %d" % [current_index, stage_order.size()], 1.0, Color(0.9, 0.96, 1.0), false)
		if RunState.get_selected_stage_id() == "stage_2":
			hud.show_cinematic_bars(34.0, 0.14)
			hud.show_event_card_temporarily(
				"LEG 2 // STORM FRONT",
				"Carry the Stage 01 route forward. Side pressure rises fast, so spend bombs before recovery space disappears.",
				1.6,
				Color(0.82, 0.94, 1.0)
			)
			get_tree().create_timer(1.45).timeout.connect(func() -> void:
				if is_instance_valid(hud):
					hud.hide_cinematic_bars(0.18)
			)
		if RunState.current_run.start_fire_level > 1 or RunState.current_run.start_bombs > 2:
			hud.show_event_card_temporarily(
				"CARRY LOADOUT",
				"Start Hull %d   Bomb %d   Fire Lv%d" % [
					int(RunState.current_run.start_lives),
					int(RunState.current_run.start_bombs),
					int(RunState.current_run.start_fire_level)
				],
				1.4,
				Color(0.72, 0.94, 1.0)
			)

	if RunState.is_autoplay():
		_queue_banner("AUTO PLAY", 1.2, Color(0.8, 0.95, 1.0), false)
	else:
		_queue_banner("SHOWCASE BUILD", 1.4, Color(1.0, 1.0, 1.0), false)


func _build_scene() -> void:
	var starfield = StarfieldScript.new().configure(String(stage_meta.get("id", "stage_1")))
	add_child(starfield)

	world_layer = Node2D.new()
	add_child(world_layer)

	bullet_layer = Node2D.new()
	bullet_layer.name = "BulletLayer"
	world_layer.add_child(bullet_layer)

	enemy_layer = Node2D.new()
	enemy_layer.name = "EnemyLayer"
	world_layer.add_child(enemy_layer)

	pickup_layer = Node2D.new()
	pickup_layer.name = "PickupLayer"
	world_layer.add_child(pickup_layer)

	hazard_layer = Node2D.new()
	hazard_layer.name = "HazardLayer"
	world_layer.add_child(hazard_layer)

	effects_layer = Node2D.new()
	effects_layer.name = "EffectsLayer"
	world_layer.add_child(effects_layer)

	if DisplayServer.get_name() != "headless":
		bgm = BgmControllerScript.new()
		add_child(bgm)
		bgm.play_stage_loop()

		sfx = SfxControllerScript.new()
		add_child(sfx)

	hud = HUDScript.new()
	hud.resume_requested.connect(_resume_run)
	hud.restart_requested.connect(_restart_run)
	hud.menu_requested.connect(_return_to_menu)
	add_child(hud)
	hud.set_stage_text(String(stage_meta.get("menu_label", "SCRAMBLE")))
	hud.set_stage_progress(0.0)
	hud.set_status_hint("BUILD FIREPOWER", Color(0.82, 0.94, 1.0))
	hud.update_player(3, 1, 2, RunState.current_run.score)

	player = PlayerScript.new().configure(playfield_rect, RunState.is_autoplay(), RunState.get_stage_start_state())
	player.position = Vector2(playfield_rect.size.x * 0.5, playfield_rect.size.y - 120.0)
	player.spawn_bullet.connect(_on_player_bullet_spawned)
	player.bomb_activated.connect(_on_player_bomb_activated)
	player.died.connect(_on_player_died)
	player.hurt.connect(_on_player_hurt)
	player.stats_changed.connect(_on_player_stats_changed)
	world_layer.add_child(player)

	last_fire_level = player.fire_level
	last_bomb_count = player.bomb_count
	hud.update_player(player.lives, player.fire_level, player.bomb_count, RunState.current_run.score)
	RunState.update_player_state(player.lives, player.bomb_count, player.fire_level)


func _setup_stage() -> void:
	stage_meta = StageCatalogScript.get_stage_meta(RunState.get_selected_stage_id())
	var stage_script = StageCatalogScript.get_stage_data_script(RunState.get_selected_stage_id())
	waves = stage_script.build_waves(playfield_rect.size)
	stage_events = stage_script.build_events(playfield_rect.size)
	boss_config = stage_script.build_boss(playfield_rect.size)


func _process(delta: float) -> void:
	var scaled_delta := delta
	if time_stop_timer > 0.0:
		time_stop_timer = max(time_stop_timer - delta, 0.0)
		scaled_delta *= time_stop_scale
	_update_screen_shake(delta)
	if run_finished or get_tree().paused:
		return

	stage_time += scaled_delta
	_process_stage_events()
	_spawn_due_waves()

	if not boss_spawned and stage_time >= boss_config.time:
		_spawn_boss()

	_update_boss_state()
	_update_hud_status()
	hud.update_player(player.lives, player.fire_level, player.bomb_count, RunState.current_run.score)


func _unhandled_input(event: InputEvent) -> void:
	if RunState.is_autoplay() or run_finished:
		return

	if event.is_action_pressed("pause_game") and not event.is_echo():
		if get_tree().paused:
			_resume_run()
		else:
			_pause_run()
		get_viewport().set_input_as_handled()
	elif not get_tree().paused and event.is_action_pressed("restart_game") and not event.is_echo():
		_restart_run()
		get_viewport().set_input_as_handled()


func _process_stage_events() -> void:
	while event_index < stage_events.size() and stage_time >= stage_events[event_index].time:
		var event: Dictionary = stage_events[event_index]
		match event.type:
			"banner":
				if event.text in ["OPENING SWEEP", "MID ASSAULT", "FINAL PUSH"]:
					hud.set_stage_text(event.text)
				elif event.text == "BOSS WARNING":
					hud.set_stage_text("BOSS ENGAGE")
				_queue_banner(event.text, event.get("duration", 1.0), _get_banner_color(event.text), false)
				if event.has("detail"):
					hud.show_event_card_temporarily(
						event.text,
						event.detail,
						event.get("card_duration", event.get("duration", 1.0) + 0.45),
						event.get("card_color", _get_banner_color(event.text))
					)
			"pickup":
				_spawn_pickup(event.position, event.pickup_type)
			"storm_strike":
				_trigger_hazard_event(event)
			"storm_cross":
				_trigger_hazard_event(event)
		event_index += 1


func _get_banner_color(text: String) -> Color:
	if text.contains("BOSS") or text.contains("WARNING"):
		return Color(1.0, 0.74, 0.36)
	if text.contains("BOMB"):
		return Color(1.0, 0.52, 0.3)
	if text.contains("FINAL"):
		return Color(1.0, 0.86, 0.46)
	if text.contains("CARRIER"):
		return Color(0.96, 0.78, 0.48)
	if text.contains("STORM"):
		return Color(0.76, 0.92, 1.0)
	return Color(0.82, 0.95, 1.0)


func _queue_banner(text: String, duration: float, color: Color = Color(1.0, 1.0, 1.0), update_stage: bool = false) -> void:
	if update_stage:
		hud.set_stage_text(text)
	hud.show_banner(text, color)
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if is_instance_valid(hud) and not get_tree().paused:
			hud.hide_banner()
	)


func _spawn_due_waves() -> void:
	while wave_index < waves.size() and stage_time >= waves[wave_index].time and not boss_spawned:
		_spawn_wave(waves[wave_index])
		wave_index += 1


func _spawn_wave(wave: Dictionary) -> void:
	_warn_wave_entry(wave)
	match wave.formation:
		"line":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -50.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.06,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 120 + int(wave.health * 1.5)
				})
		"angled_left", "angled_right":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x, wave.start_y - index * wave.gap),
					"velocity": wave.velocity,
					"pattern": "angled",
					"health": wave.health,
					"fire_interval": wave.fire_interval,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 120,
					"role": "sweeper",
					"tint": Color(0.88, 0.44, 0.26)
				})
		"sine":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x, -60.0 - index * wave.gap),
					"velocity": wave.velocity,
					"pattern": "sine",
					"health": wave.health,
					"fire_interval": wave.fire_interval,
					"drop_chance": wave.drop_chance,
					"amplitude": wave.amplitude,
					"frequency": wave.frequency,
					"phase": index * 0.55,
					"screen_rect": playfield_rect,
					"score_value": 150,
					"role": "sweeper",
					"tint": Color(0.96, 0.58, 0.2)
				})
		"wall":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -55.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.05,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 190,
					"role": "burst",
					"tint": Color(0.96, 0.28, 0.52)
				})
		"escort":
			for index in range(wave.count):
				var side := -1.0 if index % 2 == 0 else 1.0
				var lane := int(index / 2)
				_spawn_enemy({
					"position": Vector2(playfield_rect.size.x * 0.5 + side * (100.0 + lane * 55.0), -70.0 - lane * 60.0),
					"velocity": Vector2(-side * 24.0, wave.velocity.y),
					"pattern": "angled",
					"health": wave.health,
					"fire_interval": wave.fire_interval,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 180,
					"role": "burst",
					"tint": Color(0.68, 0.42, 0.98)
				})
		"sniper_line":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -56.0 - index * 28.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.08,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 220,
					"role": "sniper",
					"tint": Color(0.92, 0.74, 0.24)
				})
		"pincer_line":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -58.0 - index * 24.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.06,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 210,
					"role": "pincer",
					"tint": Color(1.0, 0.64, 0.24)
				})
		"screener_line":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -60.0 - index * 24.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.05,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 230,
					"role": "screener",
					"tint": Color(0.46, 0.8, 1.0)
				})
		"suppressor_line":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -58.0 - index * 26.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.05,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 220,
					"role": "suppressor",
					"tint": Color(1.0, 0.66, 0.3)
				})
		"dash_pair":
			for index in range(wave.count):
				var side := -1.0 if index % 2 == 0 else 1.0
				var lane := int(index / 2)
				var start_x := 52.0 if side < 0.0 else playfield_rect.size.x - 52.0
				_spawn_enemy({
					"position": Vector2(start_x, -44.0 - lane * 78.0),
					"velocity": Vector2(side * wave.velocity.x, wave.velocity.y),
					"acceleration": Vector2(side * wave.acceleration.x, wave.acceleration.y),
					"pattern": "dash",
					"health": wave.health,
					"fire_interval": wave.fire_interval,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 170,
					"role": "sweeper",
					"dash_delay": 0.25 + lane * 0.06,
					"tint": Color(1.0, 0.5, 0.24)
				})
		"carrier":
			_spawn_enemy({
				"position": Vector2(wave.position_x, -72.0),
				"velocity": wave.velocity,
				"health": wave.health,
				"fire_interval": wave.fire_interval,
				"drop_chance": wave.drop_chance,
				"drop_kind": wave.drop_kind,
				"screen_rect": playfield_rect,
				"score_value": 420,
				"role": "burst",
				"tint": Color(1.0, 0.74, 0.28)
			})
		"anchor_column":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -72.0 - index * 34.0),
					"velocity": Vector2(0.0, wave.velocity_y),
					"pattern": "hold",
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.08,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 240,
					"role": "anchor",
					"hold_y": wave.hold_y,
					"hold_duration": wave.hold_duration + index * 0.1,
					"hover_amplitude": wave.hover_amplitude,
					"frequency": wave.frequency,
					"phase": index * 0.55,
					"release_speed": wave.release_speed,
					"tint": Color(0.98, 0.66, 0.28)
				})


func _warn_wave_entry(wave: Dictionary) -> void:
	if not is_instance_valid(hud):
		return

	match wave.formation:
		"angled_left":
			hud.show_edge_warning("left", "SWEEP", 0.7, Color(1.0, 0.72, 0.4))
		"angled_right":
			hud.show_edge_warning("right", "SWEEP", 0.7, Color(1.0, 0.72, 0.4))
		"dash_pair":
			hud.show_edge_warning("left", "DASH", 0.75, Color(1.0, 0.64, 0.34))
			hud.show_edge_warning("right", "DASH", 0.75, Color(1.0, 0.64, 0.34))
		"escort":
			hud.show_edge_warning("left", "ESCORT", 0.85, Color(0.82, 0.7, 1.0))
			hud.show_edge_warning("right", "ESCORT", 0.85, Color(0.82, 0.7, 1.0))
		"screener_line":
			hud.show_edge_warning("left", "SCREEN", 0.8, Color(0.72, 0.92, 1.0))
			hud.show_edge_warning("right", "SCREEN", 0.8, Color(0.72, 0.92, 1.0))
		"suppressor_line":
			hud.show_edge_warning("left", "SUPPRESS", 0.8, Color(1.0, 0.76, 0.4))
			hud.show_edge_warning("right", "SUPPRESS", 0.8, Color(1.0, 0.76, 0.4))


func _spawn_enemy(config: Dictionary) -> void:
	var enemy = EnemyScript.new().configure(config)
	enemy.spawn_bullet.connect(_on_enemy_bullet_spawned)
	enemy.destroyed.connect(_on_enemy_destroyed)
	enemy.escaped.connect(_on_enemy_escaped)
	enemy.damaged.connect(_on_enemy_damaged)
	enemy_layer.add_child(enemy)
	RunState.register_enemy_spawn()


func _spawn_boss() -> void:
	if boss_spawned:
		return
	boss_spawned = true
	active_boss = EnemyScript.new().configure(boss_config)
	active_boss.spawn_bullet.connect(_on_enemy_bullet_spawned)
	active_boss.destroyed.connect(_on_enemy_destroyed)
	active_boss.escaped.connect(_on_enemy_escaped)
	active_boss.damaged.connect(_on_enemy_damaged)
	enemy_layer.add_child(active_boss)
	RunState.register_enemy_spawn()
	boss_phase_seen = 1
	boss_overdrive_announced = false
	boss_final_warning_announced = false
	boss_finish_window_announced = false
	boss_phase_hazard_fired = {}
	hud.set_stage_text("BOSS ENGAGE")
	hud.set_status_hint("BOSS ENTERING", Color(1.0, 0.8, 0.44))
	hud.show_cinematic_bars(40.0, 0.16)
	_play_sfx("boss_warning")
	if is_instance_valid(bgm):
		bgm.play_boss_loop()
	_show_flash(Color(1.0, 0.76, 0.38), 0.32, 0.18)
	_start_shake(8.0, 0.35)
	var intro_effect = BossIntroEffectScript.new().configure(Vector2(336.0, 154.0), 1.15, Color(1.0, 0.8, 0.44, 0.92))
	intro_effect.position = Vector2(playfield_rect.size.x * 0.5, 176.0)
	effects_layer.call_deferred("add_child", intro_effect)
	_spawn_explosion(active_boss.position + Vector2(0.0, 20.0), 1.7, true)
	var intro_banner_text := String(boss_config.get("boss_intro_banner", "WARNING // %s" % active_boss.boss_name))
	var intro_title_text := String(boss_config.get("boss_intro_title", "TARGET // %s" % active_boss.boss_name))
	var intro_detail_text := String(boss_config.get("boss_intro_detail", "Phase shifts expose the core. Hold one bomb for the late pressure window."))
	_queue_banner(intro_banner_text, 1.0, Color(1.0, 0.78, 0.4), false)
	hud.show_event_card_temporarily(
		intro_title_text,
		intro_detail_text,
		1.55,
		Color(1.0, 0.82, 0.48)
	)
	get_tree().create_timer(1.4).timeout.connect(func() -> void:
		if is_instance_valid(hud):
			hud.hide_cinematic_bars(0.2)
	)


func _update_boss_state() -> void:
	if not is_instance_valid(active_boss):
		hud.hide_boss()
		return

	var ratio := float(active_boss.health) / float(active_boss.max_health)
	var phase_index: int = _get_boss_phase(ratio)
	if phase_index != boss_phase_seen:
		boss_phase_seen = phase_index
		_handle_boss_phase_shift(phase_index)
	if String(stage_meta.get("id", "")) == "stage_2" and ratio <= 0.28 and not boss_final_warning_announced and not (active_boss.has_method("is_overdrive") and active_boss.is_overdrive()):
		boss_final_warning_announced = true
		_handle_boss_final_warning()
	if active_boss.has_method("is_overdrive") and active_boss.is_overdrive() and not boss_overdrive_announced:
		boss_overdrive_announced = true
		_handle_boss_overdrive()
	if String(stage_meta.get("id", "")) == "stage_2" and ratio <= 0.1 and not boss_finish_window_announced and active_boss.has_method("is_overdrive") and active_boss.is_overdrive():
		boss_finish_window_announced = true
		_handle_boss_finish_window()

	var phase_text := "PHASE %d" % phase_index
	if active_boss.has_method("is_overdrive") and active_boss.is_overdrive():
		phase_text += " // OVERDRIVE"
	elif active_boss.has_method("is_core_exposed") and active_boss.is_core_exposed():
		phase_text += " // CORE OPEN"
	hud.set_boss_info(active_boss.boss_name, ratio, phase_text)


func _update_hud_status() -> void:
	if not is_instance_valid(hud) or not is_instance_valid(player):
		return

	var progress_ratio := 1.0 if boss_spawned else clampf(stage_time / boss_config.time, 0.0, 1.0)
	hud.set_stage_progress(progress_ratio)

	var enemy_bullet_count := get_tree().get_nodes_in_group("enemy_projectiles").size()
	var hint_text := "BUILD FIREPOWER"
	var hint_color := Color(0.82, 0.94, 1.0)
	var danger_strength := 0.0
	var danger_color := Color(1.0, 0.28, 0.18, 1.0)

	if player.lives <= 1:
		hint_text = "CRITICAL HULL"
		hint_color = Color(1.0, 0.56, 0.46)
		danger_strength = 0.12
	elif player.bomb_count <= 0 and (boss_spawned or stage_time > boss_config.time - 5.5):
		hint_text = "NO BOMB BUFFER"
		hint_color = Color(1.0, 0.7, 0.42)
	elif player.bomb_count > 0 and enemy_bullet_count >= (10 if boss_spawned else 14):
		hint_text = "BOMB WINDOW OPEN"
		hint_color = Color(1.0, 0.76, 0.34)
	elif boss_spawned:
		if active_boss.has_method("is_overdrive") and active_boss.is_overdrive() and boss_finish_window_announced:
			hint_text = "FINISH WINDOW // BREAK CORE"
			hint_color = Color(1.0, 0.88, 0.54)
			danger_strength = max(danger_strength, 0.12)
			danger_color = Color(1.0, 0.42, 0.18, 1.0)
		elif active_boss.has_method("is_overdrive") and active_boss.is_overdrive():
			hint_text = "OVERDRIVE // HOLD LINE"
			hint_color = Color(1.0, 0.56, 0.32)
			danger_strength = max(danger_strength, 0.16)
			danger_color = Color(1.0, 0.3, 0.14, 1.0)
		elif active_boss.has_method("is_core_exposed") and active_boss.is_core_exposed():
			hint_text = "CORE EXPOSED // PUSH DAMAGE"
			hint_color = Color(1.0, 0.88, 0.52)
		elif boss_phase_seen == 3:
			hint_text = "FINAL PHASE PRESSURE"
			hint_color = Color(1.0, 0.62, 0.38)
			danger_strength = max(danger_strength, 0.1)
			danger_color = Color(1.0, 0.34, 0.18, 1.0)
		else:
			hint_text = "BREAK THE CORE"
			hint_color = Color(1.0, 0.82, 0.48)
	elif stage_time >= boss_config.time - 4.0:
		hint_text = "APPROACHING BOSS"
		hint_color = Color(1.0, 0.82, 0.48)
	elif player.fire_level < 3 and stage_time < 18.0:
		hint_text = "BUILD FIREPOWER"
		hint_color = Color(0.82, 0.94, 1.0)
	elif stage_time >= 18.0:
		hint_text = "HOLD FORMATION SPACE"
		hint_color = Color(0.92, 0.9, 1.0)

	hud.set_status_hint(hint_text, hint_color)
	hud.set_danger_overlay(danger_strength, danger_color)


func _get_boss_phase(ratio: float) -> int:
	if ratio > 0.66:
		return 1
	if ratio > 0.33:
		return 2
	return 3


func _on_player_bullet_spawned(bullet) -> void:
	bullet_layer.add_child(bullet)
	_play_sfx("player_shot")


func _on_enemy_bullet_spawned(bullet) -> void:
	bullet_layer.add_child(bullet)


func _on_player_bomb_activated(center: Vector2) -> void:
	_play_sfx("bomb")
	RunState.register_bomb_used()
	var cleared_bullets := _clear_enemy_projectiles()
	if cleared_bullets > 0:
		RunState.add_score(cleared_bullets * 8)
		_spawn_score_popup(center + Vector2(0.0, -26.0), "+%d" % int(cleared_bullets * 8), Color(1.0, 0.82, 0.42), 0.95)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("apply_damage"):
			if enemy.is_boss:
				enemy.apply_damage(110, true)
			else:
				enemy.apply_damage(999, true)

	var effect = BombEffectScript.new().configure(620.0, 0.45, Color(1.0, 0.76, 0.36), Color(0.5, 0.94, 1.0))
	effect.position = center
	effects_layer.call_deferred("add_child", effect)
	_spawn_explosion(center, 1.8, false)
	_show_flash(Color(0.8, 0.95, 1.0), 0.38, 0.16)
	hud.pulse_screen(Color(0.82, 0.94, 1.0, 0.16), 0.08)
	_start_shake(14.0, 0.24)
	_trigger_hit_stop(0.045, 0.08)

	var label_text := "BOMB DETONATION"
	if cleared_bullets > 0:
		label_text = "BOMB BONUS +%d" % int(cleared_bullets * 8)
	_queue_banner(label_text, 0.7, Color(1.0, 0.74, 0.34), false)


func _on_player_died() -> void:
	_play_sfx("player_die")
	if is_instance_valid(bgm):
		bgm.stop_all()
		bgm.play_fail_sting()
	if is_instance_valid(hud):
		hud.show_cinematic_bars(48.0, 0.12)
	_spawn_explosion(player.position, 1.3, false)
	_start_shake(12.0, 0.28)
	_show_flash(Color(1.0, 0.4, 0.36), 0.28, 0.18)
	hud.pulse_screen(Color(1.0, 0.42, 0.36, 0.18), 0.12)
	_queue_banner("MISSION FAILED", 0.9, Color(1.0, 0.55, 0.42), false)
	_finish_after_delay(false, 1.2)


func _on_player_hurt(position_value: Vector2, lives_left: int) -> void:
	_play_sfx("player_hurt")
	_spawn_impact(position_value, 1.0, Color(1.0, 0.48, 0.4, 0.95))
	_start_shake(7.0, 0.18)
	_show_flash(Color(1.0, 0.45, 0.38), 0.18, 0.1)
	if lives_left > 0:
		_queue_banner("HULL BREACH", 0.35, Color(1.0, 0.66, 0.46), false)


func _on_player_stats_changed(lives: int, bombs: int, fire_level: int) -> void:
	var fire_gained: bool = fire_level > last_fire_level
	var bombs_gained: bool = bombs > last_bomb_count
	last_fire_level = fire_level
	last_bomb_count = bombs

	RunState.update_player_state(lives, bombs, fire_level)
	if is_instance_valid(hud):
		hud.update_player(lives, fire_level, bombs, RunState.current_run.score)

	if fire_gained:
		_play_sfx("power_up")
		_show_flash(Color(0.56, 0.94, 1.0), 0.16, 0.08)
		hud.pulse_screen(Color(0.56, 0.94, 1.0, 0.1), 0.08)
		_spawn_explosion(player.position + Vector2(0.0, -12.0), 0.8 + fire_level * 0.05, false)
		_queue_banner("FIRE LEVEL %d" % fire_level, 0.55, Color(0.56, 0.94, 1.0), false)
	elif bombs_gained:
		_play_sfx("bomb_pickup")
		_show_flash(Color(1.0, 0.7, 0.34), 0.14, 0.08)
		hud.pulse_screen(Color(1.0, 0.74, 0.36, 0.1), 0.08)
		_queue_banner("BOMB STOCK +1", 0.55, Color(1.0, 0.66, 0.38), false)


func _on_enemy_damaged(enemy, amount: int, remaining_health: int) -> void:
	if not is_instance_valid(enemy) or remaining_health <= 0:
		return
	var scale := 1.0 if enemy.is_boss else 0.65
	if amount >= 40:
		scale += 0.2
	var color := Color(1.0, 0.8, 0.54, 0.95) if enemy.is_boss else Color(1.0, 0.72, 0.48, 0.92)
	_spawn_impact(enemy.position, scale, color)
	if enemy.is_boss and amount >= 18:
		_play_sfx("boss_hit")
		_trigger_hit_stop(0.024, 0.18)
	elif amount > 0:
		_play_sfx("enemy_hit")


func _on_enemy_destroyed(enemy, by_player: bool) -> void:
	_spawn_explosion(enemy.position, 1.45 if enemy.is_boss else 0.92, enemy.is_boss)
	if enemy.is_boss:
		_play_sfx("boss_break")
		_clear_enemy_projectiles()
		_start_shake(16.0, 0.35)
		_show_flash(Color(1.0, 0.88, 0.52), 0.26, 0.18)
		hud.pulse_screen(Color(1.0, 0.9, 0.56, 0.14), 0.12)
		_trigger_hit_stop(0.08, 0.05)
	else:
		_play_sfx("enemy_destroy")
		_start_shake(4.0, 0.08)
		_trigger_hit_stop(0.018, 0.3)

	if by_player:
		RunState.register_enemy_destroyed(enemy.score_value, enemy.is_boss)
		var popup_text := "+%d" % int(enemy.score_value)
		var popup_color := Color(1.0, 0.84, 0.52) if enemy.is_boss else Color(1.0, 0.88, 0.66)
		var popup_scale := 1.18 if enemy.is_boss else 0.88
		_spawn_score_popup(enemy.position + Vector2(0.0, -18.0), popup_text, popup_color, popup_scale)
		if enemy.can_drop_upgrade and _should_spawn_upgrade(enemy.drop_chance):
			_spawn_pickup(enemy.position, enemy.drop_kind)

	if enemy == active_boss:
		active_boss = null
		hud.set_status_hint("SORTIE COMPLETE", Color(1.0, 0.94, 0.58))
		_queue_banner("STAGE CLEAR", 1.1, Color(1.0, 0.95, 0.56), false)
		_play_boss_finish_sequence()


func _on_enemy_escaped(enemy) -> void:
	if enemy == active_boss:
		active_boss = null


func _should_spawn_upgrade(chance: float) -> bool:
	if chance <= 0.0:
		return false

	var guaranteed: bool = drop_fail_streak >= 4 or (RunState.current_run.upgrades_collected == 0 and RunState.current_run.enemies_destroyed >= 3)
	if guaranteed or randf() <= chance:
		drop_fail_streak = 0
		return true

	drop_fail_streak += 1
	return false


func _spawn_pickup(position_value: Vector2, kind: String = "power") -> void:
	var pickup = PickupScript.new().configure(position_value, playfield_rect, kind)
	pickup.collected.connect(_on_pickup_collected)
	pickup_layer.call_deferred("add_child", pickup)


func _trigger_hazard_event(event: Dictionary) -> void:
	match String(event.get("type", "")):
		"storm_cross":
			_trigger_storm_cross(event)
		_:
			_trigger_storm_strike(event)


func _trigger_storm_strike(event: Dictionary) -> void:
	if String(stage_meta.get("id", "")) != "stage_2":
		return
	var lanes: Array = event.get("lanes", [])
	if lanes.is_empty():
		return
	hud.show_event_card_temporarily(
		String(event.get("title", "STORM STRIKE")),
		String(event.get("detail", "Lane strike incoming. Read the telegraph and rotate early.")),
		float(event.get("card_duration", 1.2)),
		Color(0.82, 0.94, 1.0)
	)
	_queue_banner(String(event.get("banner", "STORM STRIKE")), 0.75, Color(0.82, 0.94, 1.0), false)
	_spawn_storm_strikes(
		lanes,
		float(event.get("telegraph", 0.92)),
		float(event.get("active", 0.42))
	)
	_play_sfx("boss_phase")
	_show_flash(Color(0.76, 0.9, 1.0), 0.08, 0.06)


func _trigger_storm_cross(event: Dictionary) -> void:
	if String(stage_meta.get("id", "")) != "stage_2":
		return
	var lanes: Array = event.get("lanes", [])
	var rows: Array = event.get("rows", [])
	if lanes.is_empty() and rows.is_empty():
		return
	var effect_color := Color(0.82, 0.94, 1.0)
	hud.show_event_card_temporarily(
		String(event.get("title", "STORM CROSS")),
		String(event.get("detail", "Vertical strikes and lateral sweep are collapsing the route. Commit to the gap early.")),
		float(event.get("card_duration", 1.35)),
		effect_color
	)
	_queue_banner(String(event.get("banner", "STORM CROSS")), 0.82, effect_color, false)
	if not lanes.is_empty():
		_spawn_storm_strikes(
			lanes,
			float(event.get("telegraph", 0.95)),
			float(event.get("active", 0.34))
		)
	if not rows.is_empty():
		_spawn_storm_sweeps(
			rows,
			float(event.get("telegraph", 0.95)),
			float(event.get("active", 0.34))
		)
	_play_sfx("boss_phase")
	_show_flash(Color(0.76, 0.9, 1.0), 0.1, 0.08)
	hud.pulse_screen(Color(0.82, 0.94, 1.0, 0.08), 0.06)
	_queue_support_wave(event)


func _spawn_storm_strikes(lanes: Array, telegraph_time: float, active_time: float) -> void:
	for lane_x in lanes:
		var strike = StormStrikeScript.new().configure(float(lane_x), playfield_rect, telegraph_time, active_time)
		strike.finished.connect(func() -> void:
			if is_instance_valid(hud):
				hud.pulse_screen(Color(0.82, 0.94, 1.0, 0.05), 0.05)
		)
		hazard_layer.call_deferred("add_child", strike)


func _spawn_storm_sweeps(rows: Array, telegraph_time: float, active_time: float) -> void:
	for row_y in rows:
		var sweep = StormSweepScript.new().configure(float(row_y), playfield_rect, telegraph_time, active_time)
		sweep.finished.connect(func() -> void:
			if is_instance_valid(hud):
				hud.pulse_screen(Color(0.82, 0.94, 1.0, 0.04), 0.04)
		)
		hazard_layer.call_deferred("add_child", sweep)


func _queue_support_wave(event: Dictionary) -> void:
	if not event.has("support_wave"):
		return
	var support_wave: Dictionary = event.get("support_wave", {})
	if support_wave.is_empty():
		return
	var delay := float(event.get("support_delay", 0.0))
	get_tree().create_timer(delay).timeout.connect(func() -> void:
		if run_finished:
			return
		_spawn_wave(support_wave)
	)


func _on_pickup_collected(kind: String) -> void:
	if kind == "bomb":
		_play_sfx("bomb_pickup")
		RunState.register_bomb_pickup()
		RunState.add_score(300)
		_spawn_score_popup(player.position + Vector2(0.0, -34.0), "BOMB +300", Color(1.0, 0.74, 0.44), 0.92)
	else:
		_play_sfx("power_up")
		RunState.register_upgrade_pickup()
		RunState.add_score(150)
		_spawn_score_popup(player.position + Vector2(0.0, -34.0), "POWER +150", Color(0.62, 0.94, 1.0), 0.92)


func _pause_run() -> void:
	if run_finished:
		return
	get_tree().paused = true
	hud.show_pause_menu()
	hud.show_banner("PAUSED", Color(1.0, 1.0, 1.0))


func _resume_run() -> void:
	hud.hide_pause_menu()
	get_tree().paused = false
	hud.hide_banner()


func _restart_run() -> void:
	get_tree().paused = false
	RunState.retry_run()


func _return_to_menu() -> void:
	get_tree().paused = false
	RunState.go_to_menu()


func _finish_after_delay(victory: bool, delay: float) -> void:
	if run_finished:
		return
	run_finished = true
	get_tree().paused = false
	get_tree().create_timer(delay).timeout.connect(func() -> void:
		RunState.finish_run(victory, stage_time)
	)


func _handle_boss_phase_shift(phase_index: int) -> void:
	if not is_instance_valid(active_boss):
		return
	var exposure_duration := 2.0 if phase_index == 3 else 2.4
	if active_boss.has_method("expose_core"):
		active_boss.expose_core(exposure_duration)
	var cleared_bullets := _clear_enemy_projectiles()
	if cleared_bullets > 0:
		RunState.add_score(cleared_bullets * 6)
	var label_text := "CORE OPEN"
	var label_color := Color(1.0, 0.78, 0.46)
	if phase_index == 3:
		label_text = "FINAL CORE OPEN"
		label_color = Color(1.0, 0.58, 0.34)
	var shockwave = BombEffectScript.new().configure(260.0, 0.28, label_color, Color(1.0, 0.92, 0.62))
	shockwave.position = active_boss.position
	effects_layer.call_deferred("add_child", shockwave)
	_spawn_explosion(active_boss.position, 1.45, true)
	_show_flash(label_color, 0.22, 0.12)
	_start_shake(10.0 if phase_index == 3 else 7.0, 0.24)
	_queue_banner(label_text, 0.85, label_color, false)
	hud.set_status_hint(label_text, label_color)
	hud.pulse_screen(Color(label_color.r, label_color.g, label_color.b, 0.14), 0.08)
	var phase_detail := String(boss_config.get("core_phase_detail", "The side guns are resetting. Step back in and burn the open core."))
	if phase_index == 3:
		phase_detail = String(boss_config.get("final_core_phase_detail", "Final phase has opened the core. Push damage now before overdrive speed ramps up."))
	hud.show_event_card_temporarily(label_text, phase_detail, 1.4, label_color)
	_play_sfx("boss_phase")
	_trigger_boss_hazard("phase_%d_hazard" % phase_index)


func _handle_boss_overdrive() -> void:
	if not is_instance_valid(active_boss):
		return
	var overdrive_color := Color(1.0, 0.54, 0.3)
	if is_instance_valid(bgm):
		bgm.play_boss_overdrive_loop()
	_show_flash(overdrive_color, 0.2, 0.12)
	_start_shake(12.0, 0.28)
	_queue_banner("OVERDRIVE", 0.9, overdrive_color, false)
	hud.set_status_hint("OVERDRIVE // HOLD LINE", overdrive_color)
	hud.pulse_screen(Color(overdrive_color.r, overdrive_color.g, overdrive_color.b, 0.16), 0.1)
	hud.show_event_card_temporarily(
		"OVERDRIVE",
		String(boss_config.get("overdrive_detail", "Boss speed is up. Preserve spacing first, then cash bomb or core burst windows.")),
		1.5,
		overdrive_color
	)
	_play_sfx("boss_phase")
	_trigger_boss_hazard("overdrive_hazard")


func _handle_boss_final_warning() -> void:
	if not is_instance_valid(active_boss):
		return
	var warning_color := Color(1.0, 0.74, 0.42)
	_queue_banner("LAST SAFE WINDOW", 0.9, warning_color, false)
	hud.set_status_hint("LAST SAFE WINDOW", warning_color)
	hud.show_event_card_temporarily(
		"LAST SAFE WINDOW",
		String(boss_config.get("final_warning_detail", "One last stable lane remains before overdrive. Cash bomb or core damage now, not after the collapse.")),
		1.35,
		warning_color
	)
	hud.pulse_screen(Color(warning_color.r, warning_color.g, warning_color.b, 0.16), 0.1)
	_show_flash(warning_color, 0.14, 0.08)
	_start_shake(8.0, 0.18)
	_play_sfx("boss_phase")


func _handle_boss_finish_window() -> void:
	if not is_instance_valid(active_boss):
		return
	var finish_color := Color(1.0, 0.88, 0.54)
	if active_boss.has_method("expose_core"):
		active_boss.expose_core(1.55)
	var cleared_bullets := _clear_enemy_projectiles()
	if cleared_bullets > 0:
		RunState.add_score(cleared_bullets * 10)
	var shockwave = BombEffectScript.new().configure(236.0, 0.22, finish_color, Color(1.0, 0.96, 0.72))
	shockwave.position = active_boss.position
	effects_layer.call_deferred("add_child", shockwave)
	_spawn_explosion(active_boss.position, 1.2, true)
	_queue_banner("FINISH WINDOW", 0.95, finish_color, false)
	hud.set_status_hint("FINISH WINDOW // BREAK CORE", finish_color)
	hud.show_event_card_temporarily(
		"FINISH WINDOW",
		String(boss_config.get("finish_window_detail", "Overdrive has opened one final breach line. Cash the route now before the storm fully closes again.")),
		1.45,
		finish_color
	)
	hud.pulse_screen(Color(finish_color.r, finish_color.g, finish_color.b, 0.16), 0.1)
	_show_flash(finish_color, 0.18, 0.1)
	_start_shake(10.0, 0.22)
	_trigger_hit_stop(0.028, 0.12)
	_play_sfx("boss_phase")


func _trigger_boss_hazard(config_key: String) -> void:
	if String(stage_meta.get("id", "")) != "stage_2":
		return
	if bool(boss_phase_hazard_fired.get(config_key, false)):
		return
	if not boss_config.has(config_key):
		return
	boss_phase_hazard_fired[config_key] = true
	var hazard_event: Dictionary = boss_config.get(config_key, {})
	if hazard_event.is_empty():
		return
	_trigger_hazard_event(hazard_event)


func _play_boss_finish_sequence() -> void:
	_start_shake(18.0, 0.55)
	_show_flash(Color(1.0, 0.9, 0.6), 0.24, 0.2)
	if is_instance_valid(hud):
		hud.show_cinematic_bars(52.0, 0.14)
		hud.hide_event_card()
	var finish_center := Vector2(playfield_rect.size.x * 0.5, 174.0)
	var break_effect = BossBreakEffectScript.new().configure(232.0, 0.66, Color(1.0, 0.88, 0.56, 0.96))
	break_effect.position = finish_center
	effects_layer.call_deferred("add_child", break_effect)
	var explosion_offsets := [
		Vector2(-34.0, -18.0),
		Vector2(36.0, -10.0),
		Vector2(-12.0, 20.0),
		Vector2(18.0, 12.0),
		Vector2(0.0, -30.0),
		Vector2(0.0, 0.0)
	]
	for index in range(explosion_offsets.size()):
		var delay: float = 0.08 * float(index)
		var spawn_offset: Vector2 = explosion_offsets[index]
		var spawn_scale: float = 1.15 + float(index) * 0.1
		var shake_value: float = 10.0 + float(index)
		get_tree().create_timer(delay).timeout.connect(func() -> void:
			if is_instance_valid(effects_layer):
				_spawn_explosion(finish_center + spawn_offset, spawn_scale, true)
				_start_shake(shake_value, 0.14)
		)
	get_tree().create_timer(0.22).timeout.connect(func() -> void:
		_play_sfx("stage_clear")
		if is_instance_valid(bgm):
			bgm.stop_all()
			bgm.play_clear_sting()
		_queue_banner("CLEAR BONUS", 0.8, Color(1.0, 0.86, 0.46), false)
	)
	get_tree().create_timer(0.42).timeout.connect(func() -> void:
		if is_instance_valid(hud):
			var has_chapter_link := RunState.is_chapter_mode() and StageCatalogScript.get_next_stage_id(RunState.get_selected_stage_id()) != ""
			var is_chapter_final := RunState.is_chapter_mode() and not has_chapter_link
			var clear_title := "CHAPTER SECURED" if is_chapter_final else ("STAGE LINK SECURED" if has_chapter_link else "AREA SECURED")
			hud.show_clear_summary(
				clear_title,
				(
					"Battle %06d   Kill %.0f%%   Fire Lv%d" % [
						int(RunState.current_run.score),
						RunState.get_kill_rate(),
						int(RunState.current_run.max_fire_level)
					]
					if not is_chapter_final
					else
					"Chapter finale secured   Battle %06d   Kill %.0f%%   Fire Lv%d" % [
						int(RunState.current_run.score),
						RunState.get_kill_rate(),
						int(RunState.current_run.max_fire_level)
					]
				),
				Color(1.0, 0.9, 0.58)
			)
			hud.pulse_screen(Color(1.0, 0.92, 0.68, 0.12), 0.14)
			if is_chapter_final:
				hud.show_event_card_temporarily(
					"CHAPTER COMPLETE",
					"Storm Front collapsed. The full two-stage route is secured and ready for final review.",
					1.35,
					Color(1.0, 0.9, 0.62)
				)
	)
	_finish_after_delay(true, 2.25)


func _clear_enemy_projectiles() -> int:
	var cleared_bullets := 0
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if projectile.has_method("pop"):
			cleared_bullets += 1
			projectile.pop()
	return cleared_bullets


func _spawn_impact(position_value: Vector2, scale: float = 1.0, color: Color = Color(1.0, 0.86, 0.56, 0.9)) -> void:
	var effect = ImpactEffectScript.new().configure(18.0 * scale, color)
	effect.position = position_value
	effects_layer.call_deferred("add_child", effect)


func _spawn_explosion(position_value: Vector2, scale: float = 1.0, is_boss_effect: bool = false) -> void:
	var color := Color(1.0, 0.76, 0.42, 0.95) if is_boss_effect else Color(1.0, 0.56, 0.34, 0.95)
	var effect = ExplosionEffectScript.new().configure(scale, color)
	effect.position = position_value
	effects_layer.call_deferred("add_child", effect)


func _spawn_score_popup(position_value: Vector2, text_value: String, color: Color, scale_value: float = 1.0) -> void:
	var popup = ScorePopupScript.new().configure(text_value, color, scale_value)
	popup.position = position_value
	effects_layer.call_deferred("add_child", popup)


func _play_sfx(event_name: String) -> void:
	if is_instance_valid(sfx):
		sfx.play_event(event_name)


func _show_flash(color: Color, alpha: float, duration: float) -> void:
	if not is_instance_valid(hud):
		return
	var flash := ColorRect.new()
	flash.color = Color(color.r, color.g, color.b, alpha)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(flash)
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if is_instance_valid(flash):
			flash.queue_free()
	)


func _start_shake(strength: float, duration: float) -> void:
	shake_strength = max(shake_strength, strength)
	shake_timer = max(shake_timer, duration)


func _trigger_hit_stop(duration: float, scale: float) -> void:
	time_stop_timer = max(time_stop_timer, duration)
	time_stop_scale = clampf(scale, 0.01, 1.0)


func _update_screen_shake(delta: float) -> void:
	if not is_instance_valid(world_layer):
		return
	if shake_timer > 0.0:
		shake_timer = max(shake_timer - delta, 0.0)
		shake_strength = max(shake_strength - delta * 36.0, 0.0)
		world_layer.position = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		world_layer.position = world_layer.position.lerp(Vector2.ZERO, min(1.0, delta * 18.0))
