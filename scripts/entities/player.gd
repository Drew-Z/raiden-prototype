extends Area2D
class_name Player

const BulletScript := preload("res://scripts/game/bullet.gd")

signal spawn_bullet(bullet)
signal bomb_activated(center: Vector2)
signal died
signal stats_changed(lives: int, bombs: int, fire_level: int)
signal hurt(position: Vector2, lives_left: int)

const LAYER_PLAYER := 1
const LAYER_ENEMY := 4
const LAYER_ENEMY_BULLET := 8
const LAYER_PICKUP := 16

var speed := 320.0
var lives := 3
var bomb_count := 2
var fire_level := 1
var fire_interval := 0.12
var fire_timer := 0.0
var invuln_timer := 0.0
var screen_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var autopilot := false
var alive := true
var flash_phase := 0.0
var autopilot_time := 0.0
var auto_bomb_cooldown := 0.0
var power_flash_timer := 0.0
var bomb_flash_timer := 0.0
var max_fire_level := 5
var max_bomb_count := 4
var shot_flash_timer := 0.0
var hit_flash_timer := 0.0
var option_orbit_phase := 0.0


func _init() -> void:
	monitoring = true
	monitorable = true


func _ready() -> void:
	collision_layer = LAYER_PLAYER
	collision_mask = LAYER_ENEMY | LAYER_ENEMY_BULLET | LAYER_PICKUP
	add_to_group("player")

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	collision.shape = shape
	add_child(collision)
	queue_redraw()
	stats_changed.emit(lives, bomb_count, fire_level)


func configure(bounds: Rect2, enable_autoplay: bool, start_state: Dictionary = {}):
	screen_rect = bounds
	autopilot = enable_autoplay
	lives = int(start_state.get("lives", lives))
	bomb_count = int(start_state.get("bombs", bomb_count))
	fire_level = clampi(int(start_state.get("fire_level", fire_level)), 1, max_fire_level)
	return self


func _enter_tree() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if not alive:
		return

	flash_phase += delta
	fire_timer -= delta
	invuln_timer = max(invuln_timer - delta, 0.0)
	auto_bomb_cooldown = max(auto_bomb_cooldown - delta, 0.0)
	power_flash_timer = max(power_flash_timer - delta, 0.0)
	bomb_flash_timer = max(bomb_flash_timer - delta, 0.0)
	shot_flash_timer = max(shot_flash_timer - delta, 0.0)
	hit_flash_timer = max(hit_flash_timer - delta, 0.0)
	option_orbit_phase += delta

	var direction := _get_input_direction(delta)
	position += direction * speed * delta
	position.x = clamp(position.x, screen_rect.position.x + 28.0, screen_rect.end.x - 28.0)
	position.y = clamp(position.y, screen_rect.position.y + 32.0, screen_rect.end.y - 36.0)

	if fire_timer <= 0.0:
		_shoot()
		fire_timer = _get_fire_interval()

	if Input.is_action_just_pressed("bomb"):
		trigger_bomb()
	elif autopilot and bomb_count > 0 and auto_bomb_cooldown <= 0.0:
		var enemy_bullets := get_tree().get_nodes_in_group("enemy_projectiles").size()
		var boss_active := false
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.is_boss:
				boss_active = true
				break
		if enemy_bullets >= 8 or (boss_active and enemy_bullets >= 4):
			auto_bomb_cooldown = 1.2
			trigger_bomb()

	modulate = Color(1.0, 1.0, 1.0, 0.42 if invuln_timer > 0.0 and int(flash_phase * 18.0) % 2 == 0 else 1.0)
	queue_redraw()


func _get_input_direction(delta: float) -> Vector2:
	if autopilot:
		autopilot_time += delta
		var target_x := screen_rect.size.x * 0.5 + sin(autopilot_time * 1.35) * 120.0
		var horizontal: float = clampf((target_x - position.x) / 120.0, -1.0, 1.0)
		return Vector2(horizontal, 0.1).normalized()

	var x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y := Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var direction := Vector2(x, y)
	return direction.normalized() if direction.length() > 0.0 else Vector2.ZERO


func _shoot() -> void:
	var shots: Array[Dictionary] = []
	var bullet_radius := 4.4 + fire_level * 0.35
	var bullet_tint := Color(0.42 + fire_level * 0.055, 0.95, 1.0)
	shot_flash_timer = 0.07
	match fire_level:
		1:
			shots = [{"offset": Vector2.ZERO, "dir": Vector2(0, -1), "damage": 16}]
		2:
			shots = [
				{"offset": Vector2(-10, 0), "dir": Vector2(0, -1), "damage": 15},
				{"offset": Vector2(10, 0), "dir": Vector2(0, -1), "damage": 15}
			]
		3:
			shots = [
				{"offset": Vector2.ZERO, "dir": Vector2(0, -1), "damage": 18},
				{"offset": Vector2(-16, 0), "dir": Vector2(-0.12, -1), "damage": 14},
				{"offset": Vector2(16, 0), "dir": Vector2(0.12, -1), "damage": 14}
			]
		4:
			shots = [
				{"offset": Vector2.ZERO, "dir": Vector2(0, -1), "damage": 20},
				{"offset": Vector2(-20, 0), "dir": Vector2(-0.16, -1), "damage": 14},
				{"offset": Vector2(20, 0), "dir": Vector2(0.16, -1), "damage": 14},
				{"offset": Vector2(-9, -8), "dir": Vector2(-0.05, -1), "damage": 14},
				{"offset": Vector2(9, -8), "dir": Vector2(0.05, -1), "damage": 14},
				{"offset": Vector2(0, -12), "dir": Vector2(0, -1), "damage": 16}
			]
		_:
			shots = [
				{"offset": Vector2(0, -18), "dir": Vector2(0, -1), "damage": 22},
				{"offset": Vector2(-8, -10), "dir": Vector2(-0.02, -1), "damage": 19},
				{"offset": Vector2(8, -10), "dir": Vector2(0.02, -1), "damage": 19},
				{"offset": Vector2(-18, -4), "dir": Vector2(-0.1, -1), "damage": 16},
				{"offset": Vector2(18, -4), "dir": Vector2(0.1, -1), "damage": 16},
				{"offset": Vector2(-28, 0), "dir": Vector2(-0.22, -1), "damage": 13},
				{"offset": Vector2(28, 0), "dir": Vector2(0.22, -1), "damage": 13}
			]

	for shot in shots:
		var bullet = BulletScript.new().configure(position + shot.offset + Vector2(0, -26), shot.dir.normalized() * 560.0, shot.damage, true, bullet_radius, bullet_tint, screen_rect)
		spawn_bullet.emit(bullet)

	if fire_level >= 4:
		var option_offsets: Array[Vector2] = _get_option_offsets()
		var option_count := option_offsets.size()
		for option_index in range(option_offsets.size()):
			var option_offset := option_offsets[option_index]
			var option_dir := Vector2(0.0, -1.0)
			if fire_level >= 5:
				var center_bias := float(option_index) - float(option_count - 1) * 0.5
				option_dir.x = center_bias * 0.12
			var option_bullet = BulletScript.new().configure(
				position + option_offset + Vector2(0.0, -12.0),
				option_dir.normalized() * (545.0 if fire_level >= 5 else 520.0),
				11 if fire_level >= 5 else 8,
				true,
				4.4 if fire_level >= 5 else 3.6,
				Color(0.72, 0.98, 1.0, 0.98) if fire_level >= 5 else Color(0.72, 0.98, 1.0, 0.96),
				screen_rect
			)
			spawn_bullet.emit(option_bullet)


func trigger_bomb() -> void:
	if not alive or bomb_count <= 0:
		return
	bomb_count -= 1
	invuln_timer = max(invuln_timer, 1.15)
	bomb_flash_timer = 0.5
	stats_changed.emit(lives, bomb_count, fire_level)
	bomb_activated.emit(position)


func apply_damage(amount: int = 1) -> void:
	if not alive or invuln_timer > 0.0:
		return
	lives -= amount
	invuln_timer = 1.2
	hit_flash_timer = 0.32
	stats_changed.emit(lives, bomb_count, fire_level)
	hurt.emit(position, lives)
	if lives <= 0:
		alive = false
		died.emit()


func add_firepower() -> void:
	if fire_level < max_fire_level:
		fire_level += 1
	power_flash_timer = 0.5
	stats_changed.emit(lives, bomb_count, fire_level)


func add_bomb(amount: int = 1) -> void:
	bomb_count = min(max_bomb_count, bomb_count + amount)
	bomb_flash_timer = 0.6
	stats_changed.emit(lives, bomb_count, fire_level)


func _get_fire_interval() -> float:
	match fire_level:
		1:
			return 0.12
		2:
			return 0.112
		3:
			return 0.102
		4:
			return 0.094
		_:
			return 0.078


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hazards"):
		apply_damage(1)
	elif area.is_in_group("enemy_projectiles"):
		area.pop()
		apply_damage(1)
	elif area.is_in_group("enemies"):
		apply_damage(1)
	elif area.collision_layer == LAYER_PICKUP:
		var kind: String = area.pickup_type
		area.collect()
		if kind == "bomb":
			add_bomb()
		else:
			add_firepower()


func _get_option_offsets() -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	if fire_level < 4:
		return offsets
	if fire_level >= 5:
		var front_y := -4.0 + sin(option_orbit_phase * 3.6) * 2.4
		var rear_y := 6.0 - sin(option_orbit_phase * 3.2) * 2.2
		offsets.append(Vector2(-34.0 + sin(option_orbit_phase * 1.8) * 2.4, rear_y))
		offsets.append(Vector2(-18.0 + sin(option_orbit_phase * 2.2) * 1.6, front_y))
		offsets.append(Vector2(18.0 - sin(option_orbit_phase * 2.2) * 1.6, front_y))
		offsets.append(Vector2(34.0 - sin(option_orbit_phase * 1.8) * 2.4, rear_y))
		return offsets
	var hover_y := 2.0 + sin(option_orbit_phase * 3.2) * 3.0
	offsets.append(Vector2(-24.0 + sin(option_orbit_phase * 2.1) * 2.0, hover_y))
	offsets.append(Vector2(24.0 - sin(option_orbit_phase * 2.1) * 2.0, hover_y))
	return offsets


func _draw() -> void:
	if lives <= 1:
		var warning_alpha: float = 0.08 + abs(sin(flash_phase * 6.0)) * 0.12
		draw_circle(Vector2.ZERO, 24.0 + abs(sin(flash_phase * 8.0)) * 4.0, Color(1.0, 0.42, 0.36, warning_alpha))
	if fire_level >= 3:
		var aura_alpha := 0.08 + float(fire_level - 2) * 0.04 + power_flash_timer * 0.12
		draw_circle(Vector2.ZERO, 18.0 + fire_level * 1.5, Color(0.35, 0.85, 1.0, aura_alpha))
	if bomb_flash_timer > 0.0:
		draw_circle(Vector2.ZERO, 28.0 + bomb_flash_timer * 18.0, Color(1.0, 0.58, 0.3, 0.14))
	if hit_flash_timer > 0.0:
		draw_circle(Vector2.ZERO, 24.0 + hit_flash_timer * 18.0, Color(1.0, 0.38, 0.34, 0.22))

	var body := PackedVector2Array([
		Vector2(0, -24),
		Vector2(15, 18),
		Vector2(0, 10),
		Vector2(-15, 18)
	])
	var wings := PackedVector2Array([
		Vector2(-22, 10),
		Vector2(-8, -2),
		Vector2(0, 16),
		Vector2(8, -2),
		Vector2(22, 10),
		Vector2(0, 22)
	])
	draw_colored_polygon(body, Color(0.25, 0.92, 1.0, 0.95))
	draw_colored_polygon(wings, Color(0.11, 0.54, 0.95, 0.85))
	for option_offset in _get_option_offsets():
		draw_circle(option_offset, 6.0, Color(0.62, 0.94, 1.0, 0.92))
		draw_circle(option_offset, 3.0, Color(1.0, 0.98, 0.84, 0.94))
		draw_line(option_offset, option_offset + Vector2(0.0, 10.0), Color(1.0, 0.72, 0.34, 0.54), 2.0)
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.95, 0.8))
	if bomb_count <= 0:
		draw_arc(Vector2.ZERO, 20.0, PI * 0.15, PI * 0.85, 18, Color(1.0, 0.56, 0.4, 0.24), 2.0)
	if shot_flash_timer > 0.0:
		draw_circle(Vector2(0, -26), 6.0 + shot_flash_timer * 22.0, Color(1.0, 0.96, 0.76, 0.18))
	var engine_flame := PackedVector2Array([
		Vector2(-5, 18),
		Vector2(0, 28 + sin(flash_phase * 30.0) * 2.0),
		Vector2(5, 18)
	])
	draw_colored_polygon(engine_flame, Color(1.0, 0.66, 0.3, 0.78))
