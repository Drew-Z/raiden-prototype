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


func configure(bounds: Rect2, enable_autoplay: bool):
	screen_rect = bounds
	autopilot = enable_autoplay
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
	var bullet_radius := 4.5 + fire_level * 0.2
	var bullet_tint := Color(0.45 + fire_level * 0.04, 0.95, 1.0)
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
				{"offset": Vector2.ZERO, "dir": Vector2(0, -1), "damage": 16},
				{"offset": Vector2(-16, 0), "dir": Vector2(-0.12, -1), "damage": 13},
				{"offset": Vector2(16, 0), "dir": Vector2(0.12, -1), "damage": 13}
			]
		4:
			shots = [
				{"offset": Vector2.ZERO, "dir": Vector2(0, -1), "damage": 16},
				{"offset": Vector2(-18, 0), "dir": Vector2(-0.16, -1), "damage": 13},
				{"offset": Vector2(18, 0), "dir": Vector2(0.16, -1), "damage": 13},
				{"offset": Vector2(-8, -8), "dir": Vector2(-0.05, -1), "damage": 12},
				{"offset": Vector2(8, -8), "dir": Vector2(0.05, -1), "damage": 12}
			]
		_:
			shots = [
				{"offset": Vector2.ZERO, "dir": Vector2(0, -1), "damage": 18},
				{"offset": Vector2(-22, 0), "dir": Vector2(-0.2, -1), "damage": 14},
				{"offset": Vector2(22, 0), "dir": Vector2(0.2, -1), "damage": 14},
				{"offset": Vector2(-10, -10), "dir": Vector2(-0.08, -1), "damage": 13},
				{"offset": Vector2(10, -10), "dir": Vector2(0.08, -1), "damage": 13},
				{"offset": Vector2(0, -14), "dir": Vector2(0, -1), "damage": 10}
			]

	for shot in shots:
		var bullet = BulletScript.new().configure(position + shot.offset + Vector2(0, -26), shot.dir.normalized() * 560.0, shot.damage, true, bullet_radius, bullet_tint, screen_rect)
		spawn_bullet.emit(bullet)


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
	return max(0.07, fire_interval - float(fire_level - 1) * 0.008)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_projectiles"):
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


func _draw() -> void:
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
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.95, 0.8))
	if shot_flash_timer > 0.0:
		draw_circle(Vector2(0, -26), 6.0 + shot_flash_timer * 22.0, Color(1.0, 0.96, 0.76, 0.18))
	var engine_flame := PackedVector2Array([
		Vector2(-5, 18),
		Vector2(0, 28 + sin(flash_phase * 30.0) * 2.0),
		Vector2(5, 18)
	])
	draw_colored_polygon(engine_flame, Color(1.0, 0.66, 0.3, 0.78))
