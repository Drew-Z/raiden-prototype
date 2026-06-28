extends Node2D

const PlayerScript := preload("res://scripts/entities/player.gd")
const EnemyScript := preload("res://scripts/entities/enemy.gd")
const PickupScript := preload("res://scripts/entities/pickup.gd")
const StarfieldScript := preload("res://scripts/game/starfield.gd")
const HUDScript := preload("res://scripts/ui/hud.gd")
const StageDataScript := preload("res://scripts/game/stage_data.gd")

var playfield_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var player
var hud
var world_layer: Node2D
var bullet_layer: Node2D
var enemy_layer: Node2D
var pickup_layer: Node2D
var waves: Array[Dictionary] = []
var boss_config: Dictionary = {}
var wave_index := 0
var stage_time := 0.0
var run_finished := false
var boss_spawned := false
var active_boss
var drop_fail_streak := 0


func _ready() -> void:
	randomize()
	_build_scene()
	_setup_stage()

	if RunState.is_autoplay():
		hud.show_banner("AUTO PLAY")
	else:
		hud.show_banner("PHASE 1")

	get_tree().create_timer(1.8).timeout.connect(func() -> void:
		if is_instance_valid(hud):
			hud.hide_banner()
	)


func _build_scene() -> void:
	var starfield = StarfieldScript.new()
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

	hud = HUDScript.new()
	add_child(hud)
	hud.update_player(3, 1, 2, RunState.current_run.score)

	player = PlayerScript.new().configure(playfield_rect, RunState.is_autoplay())
	player.position = Vector2(playfield_rect.size.x * 0.5, playfield_rect.size.y - 120.0)
	player.spawn_bullet.connect(_on_player_bullet_spawned)
	player.bomb_activated.connect(_on_player_bomb_activated)
	player.died.connect(_on_player_died)
	player.stats_changed.connect(_on_player_stats_changed)
	world_layer.add_child(player)

	hud.update_player(player.lives, player.fire_level, player.bomb_count, RunState.current_run.score)
	RunState.update_player_state(player.lives, player.bomb_count, player.fire_level)


func _setup_stage() -> void:
	waves = StageDataScript.build_waves(playfield_rect.size)
	boss_config = StageDataScript.build_boss(playfield_rect.size)


func _process(delta: float) -> void:
	if run_finished:
		return

	stage_time += delta
	_spawn_due_waves()

	if not boss_spawned and stage_time >= boss_config.time:
		_spawn_boss()

	if is_instance_valid(active_boss):
		hud.set_boss_info(active_boss.boss_name, float(active_boss.health) / float(active_boss.max_health))
	else:
		hud.hide_boss()

	hud.update_player(player.lives, player.fire_level, player.bomb_count, RunState.current_run.score)


func _spawn_due_waves() -> void:
	while wave_index < waves.size() and stage_time >= waves[wave_index].time and not boss_spawned:
		_spawn_wave(waves[wave_index])
		wave_index += 1


func _spawn_wave(wave: Dictionary) -> void:
	match wave.formation:
		"line":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -50.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.08,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 120
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
					"score_value": 110,
					"tint": Color(0.85, 0.42, 0.28)
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
					"score_value": 140,
					"tint": Color(0.91, 0.54, 0.23)
				})
		"wall":
			for index in range(wave.count):
				_spawn_enemy({
					"position": Vector2(wave.start_x + index * wave.gap, -55.0),
					"velocity": wave.velocity,
					"health": wave.health,
					"fire_interval": wave.fire_interval + index * 0.04,
					"drop_chance": wave.drop_chance,
					"screen_rect": playfield_rect,
					"score_value": 180,
					"tint": Color(0.95, 0.28, 0.52)
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
					"score_value": 170,
					"tint": Color(0.67, 0.4, 0.98)
				})


func _spawn_enemy(config: Dictionary) -> void:
	var enemy = EnemyScript.new().configure(config)
	enemy.spawn_bullet.connect(_on_enemy_bullet_spawned)
	enemy.destroyed.connect(_on_enemy_destroyed)
	enemy.escaped.connect(_on_enemy_escaped)
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
	enemy_layer.add_child(active_boss)
	RunState.register_enemy_spawn()
	hud.show_banner("BOSS WARNING")
	get_tree().create_timer(1.8).timeout.connect(func() -> void:
		if is_instance_valid(hud):
			hud.hide_banner()
	)


func _on_player_bullet_spawned(bullet) -> void:
	bullet_layer.add_child(bullet)


func _on_enemy_bullet_spawned(bullet) -> void:
	bullet_layer.add_child(bullet)


func _on_player_bomb_activated(_center: Vector2) -> void:
	RunState.register_bomb_used()
	hud.show_banner("BOMB")
	get_tree().create_timer(0.6).timeout.connect(func() -> void:
		if is_instance_valid(hud) and not run_finished:
			hud.hide_banner()
	)

	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if projectile.has_method("pop"):
			projectile.pop()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("apply_damage"):
			if enemy.is_boss:
				enemy.apply_damage(90, true)
			else:
				enemy.apply_damage(999, true)

	var flash := ColorRect.new()
	flash.color = Color(0.8, 0.95, 1.0, 0.4)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(flash)
	get_tree().create_timer(0.16).timeout.connect(func() -> void:
		if is_instance_valid(flash):
			flash.queue_free()
	)


func _on_player_died() -> void:
	hud.show_banner("MISSION FAILED")
	_finish_after_delay(false, 1.2)


func _on_player_stats_changed(lives: int, bombs: int, fire_level: int) -> void:
	RunState.update_player_state(lives, bombs, fire_level)
	if is_instance_valid(hud):
		hud.update_player(lives, fire_level, bombs, RunState.current_run.score)


func _on_enemy_destroyed(enemy, by_player: bool) -> void:
	if by_player:
		RunState.register_enemy_destroyed(enemy.score_value, enemy.is_boss)
		if enemy.can_drop_upgrade and _should_spawn_upgrade(enemy.drop_chance):
			_spawn_pickup(enemy.position)

	if enemy == active_boss:
		active_boss = null
		hud.show_banner("STAGE CLEAR")
		_finish_after_delay(true, 1.4)


func _on_enemy_escaped(enemy) -> void:
	if enemy == active_boss:
		active_boss = null


func _should_spawn_upgrade(chance: float) -> bool:
	if chance <= 0.0:
		return false

	var guaranteed: bool = drop_fail_streak >= 6 or (RunState.current_run.upgrades_collected == 0 and RunState.current_run.enemies_destroyed >= 5)
	if guaranteed or randf() <= chance:
		drop_fail_streak = 0
		return true

	drop_fail_streak += 1
	return false


func _spawn_pickup(position_value: Vector2) -> void:
	var pickup = PickupScript.new().configure(position_value, playfield_rect)
	pickup.collected.connect(_on_pickup_collected)
	pickup_layer.call_deferred("add_child", pickup)


func _on_pickup_collected(kind: String = "power") -> void:
	if kind == "bomb":
		RunState.register_bomb_pickup()
		RunState.add_score(300)
		hud.show_banner("BOMB STOCK")
	else:
		RunState.register_upgrade_pickup()
		RunState.add_score(150)
		hud.show_banner("POWER UP")
	get_tree().create_timer(0.5).timeout.connect(func() -> void:
		if is_instance_valid(hud) and not run_finished and not is_instance_valid(active_boss):
			hud.hide_banner()
	)


func _finish_after_delay(victory: bool, delay: float) -> void:
	if run_finished:
		return
	run_finished = true
	get_tree().create_timer(delay).timeout.connect(func() -> void:
		RunState.finish_run(victory, stage_time)
	)
