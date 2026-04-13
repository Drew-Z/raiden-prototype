extends Area2D
class_name Enemy

const BulletScript := preload("res://scripts/game/bullet.gd")

signal spawn_bullet(bullet)
signal destroyed(enemy, by_player: bool)
signal escaped(enemy)
signal damaged(enemy, amount: int, remaining_health: int)

const LAYER_PLAYER := 1
const LAYER_PLAYER_BULLET := 2
const LAYER_ENEMY := 4

var health := 24
var max_health := 24
var velocity := Vector2(0, 180)
var movement_pattern := "straight"
var score_value := 120
var bullet_speed := 220.0
var fire_interval := 1.8
var fire_timer := 0.8
var amplitude := 0.0
var frequency := 0.0
var phase := 0.0
var spawn_x := 0.0
var can_drop_upgrade := true
var drop_chance := 0.28
var drop_kind := "power"
var screen_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var is_boss := false
var boss_name := ""
var target_y := 160.0
var boss_anchor_x := 270.0
var elapsed := 0.0
var entered_screen := false
var base_tint := Color(0.95, 0.33, 0.33)
var alive := true
var volley_index := 0
var enemy_role := "standard"
var acceleration := Vector2.ZERO
var dash_delay := 0.0
var impact_flash_timer := 0.0
var telegraph_window := 0.34
var hold_y := 180.0
var hold_duration := 1.4
var hover_amplitude := 18.0
var release_speed := 170.0
var core_exposed_timer := 0.0
var core_exposed_duration := 2.2
var core_damage_multiplier := 1.65
var overdrive_threshold := 0.18
var boss_style := "carrier"


func _init() -> void:
	monitoring = true
	monitorable = true


func _enter_tree() -> void:
	area_entered.connect(_on_area_entered)


func _ready() -> void:
	collision_layer = LAYER_ENEMY
	collision_mask = LAYER_PLAYER | LAYER_PLAYER_BULLET
	add_to_group("enemies")

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 18.0 if not is_boss else 44.0
	collision.shape = shape
	add_child(collision)
	queue_redraw()


func configure(config: Dictionary):
	position = config.get("position", Vector2.ZERO)
	spawn_x = position.x
	velocity = config.get("velocity", Vector2(0, 180))
	movement_pattern = config.get("pattern", "straight")
	health = config.get("health", 24)
	max_health = health
	score_value = config.get("score_value", 120)
	fire_interval = config.get("fire_interval", 1.8)
	fire_timer = config.get("fire_timer", fire_interval)
	amplitude = config.get("amplitude", 0.0)
	frequency = config.get("frequency", 0.0)
	phase = config.get("phase", 0.0)
	can_drop_upgrade = config.get("can_drop_upgrade", true)
	drop_chance = config.get("drop_chance", 0.28)
	drop_kind = config.get("drop_kind", "power")
	screen_rect = config.get("screen_rect", screen_rect)
	is_boss = config.get("is_boss", false)
	target_y = config.get("target_y", 160.0)
	boss_anchor_x = config.get("boss_anchor_x", position.x)
	boss_name = config.get("boss_name", "HX-1")
	bullet_speed = config.get("bullet_speed", 220.0)
	base_tint = config.get("tint", Color(0.95, 0.33, 0.33))
	enemy_role = config.get("role", "standard")
	acceleration = config.get("acceleration", Vector2.ZERO)
	dash_delay = config.get("dash_delay", 0.0)
	hold_y = config.get("hold_y", 180.0)
	hold_duration = config.get("hold_duration", 1.4)
	hover_amplitude = config.get("hover_amplitude", 18.0)
	release_speed = config.get("release_speed", 170.0)
	core_exposed_duration = config.get("core_exposed_duration", 2.2)
	core_damage_multiplier = config.get("core_damage_multiplier", 1.65)
	overdrive_threshold = config.get("overdrive_threshold", 0.18)
	boss_style = config.get("boss_style", "carrier")
	return self


func _physics_process(delta: float) -> void:
	if not alive:
		return

	elapsed += delta
	fire_timer -= delta
	impact_flash_timer = max(impact_flash_timer - delta, 0.0)
	core_exposed_timer = max(core_exposed_timer - delta, 0.0)

	match movement_pattern:
		"straight":
			position += velocity * delta
		"sine":
			position.y += velocity.y * delta
			position.x = spawn_x + sin(elapsed * frequency + phase) * amplitude
		"angled":
			position += velocity * delta
		"dash":
			if elapsed < dash_delay:
				position += Vector2(velocity.x * 0.45, velocity.y * 0.62) * delta
			else:
				velocity += acceleration * delta
				position += velocity * delta
		"hold":
			if position.y < hold_y:
				position.y = min(hold_y, position.y + velocity.y * delta)
			elif elapsed < hold_duration:
				position.x = spawn_x + sin(elapsed * frequency + phase) * hover_amplitude
			else:
				position.y += release_speed * delta
				position.x = spawn_x + sin(elapsed * frequency + phase) * hover_amplitude * 0.55
		"boss":
			var boss_ratio := float(health) / float(max_health)
			var move_amplitude := amplitude
			var move_frequency := frequency
			if boss_ratio <= overdrive_threshold:
				move_amplitude *= 1.18
				move_frequency *= 1.26
			if position.y < target_y:
				position.y = min(target_y, position.y + 110.0 * delta)
			else:
				position.x = boss_anchor_x + sin(elapsed * move_frequency) * move_amplitude

	if screen_rect.has_point(position):
		entered_screen = true

	if fire_interval > 0.0 and fire_timer <= 0.0 and (entered_screen or is_boss):
		_fire()
		fire_timer = _get_fire_delay()

	if not is_boss and entered_screen and not screen_rect.grow(80.0).has_point(position):
		escaped.emit(self)
		queue_free()

	queue_redraw()


func _fire() -> void:
	if is_boss:
		_fire_boss_pattern()
	else:
		match enemy_role:
			"sniper":
				_fire_sniper_pattern()
			"burst":
				_fire_burst_pattern()
			"suppressor":
				_fire_suppressor_pattern()
			"sweeper":
				_fire_sweeper_pattern()
			"anchor":
				_fire_anchor_pattern()
			"pincer":
				_fire_pincer_pattern()
			"screener":
				_fire_screener_pattern()
			_:
				_fire_standard_pattern()
	volley_index += 1


func _fire_boss_pattern() -> void:
	if boss_style == "storm":
		_fire_storm_boss_pattern()
		return

	var ratio := float(health) / float(max_health)
	if ratio > 0.66:
		for offset in [-0.42, -0.21, 0.0, 0.21, 0.42]:
			_spawn_boss_bullet(offset, 6.0, Color(1.0, 0.45, 0.35))
		if volley_index % 2 == 0:
			_spawn_targeted_bullet(0.0, 6.4, Color(1.0, 0.8, 0.56), 1.12)
	elif ratio > 0.33:
		for offset in [-0.62, -0.36, -0.12, 0.12, 0.36, 0.62]:
			_spawn_boss_bullet(offset, 6.5, Color(1.0, 0.56, 0.3))
		for aim_offset in [-0.14, 0.14]:
			_spawn_targeted_bullet(aim_offset, 6.2, Color(1.0, 0.78, 0.48), 1.16)
		if volley_index % 2 == 0:
			for offset in [-0.18, 0.0, 0.18]:
				_spawn_boss_bullet(offset, 7.0, Color(1.0, 0.72, 0.42), 1.14)
	else:
		var sweep := sin(elapsed * 1.8) * 0.18
		for offset in [-0.72, -0.48, -0.24, 0.0, 0.24, 0.48, 0.72]:
			_spawn_boss_bullet(offset + sweep, 7.0, Color(1.0, 0.5, 0.24), 1.08)
		for aim_offset in [-0.2, 0.0, 0.2]:
			_spawn_targeted_bullet(aim_offset, 5.8, Color(1.0, 0.9, 0.62), 1.28)
		if volley_index % 2 == 1:
			for offset in [-0.3, 0.3]:
				_spawn_boss_bullet(offset - sweep * 0.6, 6.4, Color(1.0, 0.68, 0.36), 1.34)
		if ratio <= overdrive_threshold:
			for aim_offset in [-0.34, 0.34]:
				_spawn_targeted_bullet(aim_offset, 6.2, Color(1.0, 0.96, 0.72), 1.42)
			if volley_index % 2 == 0:
				for offset in [-0.12, 0.12]:
					_spawn_boss_bullet(offset + sweep * 0.5, 6.8, Color(1.0, 0.72, 0.3), 1.4)


func _fire_storm_boss_pattern() -> void:
	var ratio := float(health) / float(max_health)
	if ratio > 0.66:
		for offset in [-0.58, -0.3, 0.0, 0.3, 0.58]:
			_spawn_boss_bullet(offset, 6.1, Color(1.0, 0.58, 0.36), 1.04)
		if volley_index % 2 == 0:
			for aim_offset in [-0.22, 0.22]:
				_spawn_targeted_bullet(aim_offset, 5.8, Color(1.0, 0.88, 0.6), 1.14)
	elif ratio > 0.33:
		for offset in [-0.82, -0.52, -0.24, 0.0, 0.24, 0.52, 0.82]:
			_spawn_boss_bullet(offset, 6.5, Color(1.0, 0.52, 0.3), 1.08)
		for offset in [-0.34, 0.34]:
			_spawn_boss_bullet(offset, 7.0, Color(1.0, 0.74, 0.44), 1.24)
		for aim_offset in [-0.28, 0.28]:
			_spawn_targeted_bullet(aim_offset, 5.8, Color(1.0, 0.94, 0.68), 1.18)
	else:
		var sweep := sin(elapsed * 2.1) * 0.24
		for offset in [-0.92, -0.62, -0.34, -0.08, 0.08, 0.34, 0.62, 0.92]:
			_spawn_boss_bullet(offset + sweep, 6.7, Color(1.0, 0.48, 0.24), 1.12)
		for aim_offset in [-0.3, 0.0, 0.3]:
			_spawn_targeted_bullet(aim_offset, 5.9, Color(1.0, 0.96, 0.72), 1.28)
		if volley_index % 2 == 1:
			for offset in [-0.48, 0.48]:
				_spawn_boss_bullet(offset - sweep * 0.4, 7.2, Color(1.0, 0.74, 0.38), 1.34)
		if ratio <= overdrive_threshold:
			for aim_offset in [-0.42, -0.16, 0.16, 0.42]:
				_spawn_targeted_bullet(aim_offset, 5.4, Color(1.0, 0.98, 0.76), 1.48)


func _fire_standard_pattern() -> void:
	var bullet = BulletScript.new().configure(position + Vector2(0, 18), Vector2(0, bullet_speed), 1, false, 5.0, Color(1.0, 0.5, 0.35), screen_rect)
	spawn_bullet.emit(bullet)


func _fire_sniper_pattern() -> void:
	var bullet_color := Color(1.0, 0.82, 0.44)
	_spawn_targeted_bullet(0.0 if volley_index % 2 == 0 else 0.06, 6.2, bullet_color, 1.18)


func _fire_burst_pattern() -> void:
	for offset in [-0.18, 0.0, 0.18]:
		var bullet = BulletScript.new().configure(
			position + Vector2(offset * 22.0, 18.0),
			Vector2(offset, 1.0).normalized() * bullet_speed,
			1,
			false,
			5.6,
			Color(1.0, 0.56, 0.34),
			screen_rect
		)
		spawn_bullet.emit(bullet)


func _fire_suppressor_pattern() -> void:
	for offset in [-0.34, -0.17, 0.0, 0.17, 0.34]:
		var bullet = BulletScript.new().configure(
			position + Vector2(offset * 18.0, 18.0),
			Vector2(offset * 0.72, 1.0).normalized() * bullet_speed * 0.98,
			1,
			false,
			5.8,
			Color(1.0, 0.7, 0.34),
			screen_rect
		)
		spawn_bullet.emit(bullet)


func _fire_sweeper_pattern() -> void:
	for offset in [-0.3, 0.3]:
		var bullet = BulletScript.new().configure(
			position + Vector2(offset * 24.0, 18.0),
			Vector2(offset, 1.0).normalized() * bullet_speed * 1.08,
			1,
			false,
			5.2,
			Color(1.0, 0.68, 0.38),
			screen_rect
		)
		spawn_bullet.emit(bullet)


func _fire_anchor_pattern() -> void:
	for offset in [-0.38, -0.18, 0.0, 0.18, 0.38]:
		var bullet = BulletScript.new().configure(
			position + Vector2(offset * 20.0, 18.0),
			Vector2(offset, 1.0).normalized() * bullet_speed * 0.96,
			1,
			false,
			5.8,
			Color(1.0, 0.66, 0.34),
			screen_rect
		)
		spawn_bullet.emit(bullet)


func _fire_pincer_pattern() -> void:
	for aim_offset in [-0.24, 0.24]:
		_spawn_targeted_bullet(aim_offset, 5.8, Color(1.0, 0.78, 0.4), 1.18)
	if volley_index % 2 == 1:
		_spawn_targeted_bullet(0.0, 5.2, Color(1.0, 0.9, 0.62), 1.08)


func _fire_screener_pattern() -> void:
	var offsets := [-0.42, 0.0, 0.42] if volley_index % 2 == 0 else [-0.24, 0.24]
	for offset in offsets:
		var bullet = BulletScript.new().configure(
			position + Vector2(offset * 24.0, 20.0),
			Vector2(offset * 0.35, 1.0).normalized() * bullet_speed * 0.82,
			1,
			false,
			6.6,
			Color(0.72, 0.92, 1.0),
			screen_rect
		)
		spawn_bullet.emit(bullet)


func _spawn_boss_bullet(horizontal: float, bullet_radius: float, bullet_color: Color, speed_scale: float = 1.0) -> void:
	var direction := Vector2(horizontal, 1.0).normalized()
	var bullet = BulletScript.new().configure(position + Vector2(horizontal * 52.0, 36.0), direction * bullet_speed * speed_scale, 1, false, bullet_radius, bullet_color, screen_rect)
	spawn_bullet.emit(bullet)


func _spawn_targeted_bullet(horizontal_bias: float, bullet_radius: float, bullet_color: Color, speed_scale: float = 1.0) -> void:
	var direction := _get_player_direction()
	direction.x += horizontal_bias
	direction = direction.normalized()
	var bullet = BulletScript.new().configure(position + Vector2(direction.x * 18.0, 22.0), direction * bullet_speed * speed_scale, 1, false, bullet_radius, bullet_color, screen_rect)
	spawn_bullet.emit(bullet)


func _get_player_direction() -> Vector2:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return Vector2.DOWN
	var player = players[0]
	if not is_instance_valid(player):
		return Vector2.DOWN
	return (player.position - position).normalized()


func _get_fire_delay() -> float:
	if not is_boss:
		return fire_interval

	var ratio := float(health) / float(max_health)
	if ratio > 0.66:
		return fire_interval
	if ratio > 0.33:
		return max(0.64, fire_interval - 0.18)
	return max(0.5, fire_interval - 0.28)


func expose_core(duration: float = -1.0) -> void:
	var open_time := core_exposed_duration if duration <= 0.0 else duration
	core_exposed_timer = max(core_exposed_timer, open_time)
	fire_timer = max(fire_timer, 0.4)
	queue_redraw()


func is_core_exposed() -> bool:
	return core_exposed_timer > 0.0


func is_overdrive() -> bool:
	return is_boss and float(health) / float(max_health) <= overdrive_threshold


func apply_damage(amount: int, by_player: bool = true) -> void:
	if not alive:
		return
	var applied_amount := amount
	if is_boss and by_player and is_core_exposed():
		applied_amount = maxi(1, int(round(float(amount) * core_damage_multiplier)))
	health -= applied_amount
	impact_flash_timer = 0.18 if is_boss and is_core_exposed() else 0.12
	damaged.emit(self, applied_amount, max(0, health))
	if health <= 0:
		alive = false
		destroyed.emit(self, by_player)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_projectiles"):
		area.pop()
		apply_damage(area.damage, true)


func _draw() -> void:
	if is_boss:
		var ratio := float(health) / float(max_health)
		var exposed_alpha := clampf(core_exposed_timer / max(core_exposed_duration, 0.01), 0.0, 1.0)
		var core_alpha := 0.72 + (1.0 - ratio) * 0.18 + impact_flash_timer * 1.2 + exposed_alpha * 0.22
		draw_circle(Vector2.ZERO, 50.0, Color(0.24, 0.1, 0.1, 0.96))
		if boss_style == "storm":
			var left_wing := PackedVector2Array([
				Vector2(-76, -8),
				Vector2(-112, 2),
				Vector2(-78, 20),
				Vector2(-54, 10)
			])
			var right_wing := PackedVector2Array([
				Vector2(76, -8),
				Vector2(112, 2),
				Vector2(78, 20),
				Vector2(54, 10)
			])
			draw_colored_polygon(left_wing, base_tint.darkened(0.12).lightened(impact_flash_timer * 0.8))
			draw_colored_polygon(right_wing, base_tint.darkened(0.12).lightened(impact_flash_timer * 0.8))
			draw_rect(Rect2(Vector2(-60, -26), Vector2(120, 56)), base_tint.lightened(impact_flash_timer * 0.8), true)
			draw_rect(Rect2(Vector2(-26, -56), Vector2(52, 24)), Color(0.82, 0.94, 1.0, 0.92), true)
			draw_rect(Rect2(Vector2(-94, -12), Vector2(26, 28)), Color(0.5, 0.12, 0.12, 0.95), true)
			draw_rect(Rect2(Vector2(68, -12), Vector2(26, 28)), Color(0.5, 0.12, 0.12, 0.95), true)
			draw_rect(Rect2(Vector2(-44, 18), Vector2(88, 18)), Color(0.38, 0.12, 0.12, 0.94), true)
			draw_arc(Vector2.ZERO, 32.0, 0.0, TAU, 32, Color(0.74, 0.92, 1.0, 0.18 + exposed_alpha * 0.24), 3.0)
		else:
			draw_rect(Rect2(Vector2(-58, -30), Vector2(116, 60)), base_tint.lightened(impact_flash_timer * 0.8), true)
			draw_rect(Rect2(Vector2(-28, -54), Vector2(56, 26)), Color(1.0, 0.78, 0.3, 0.95), true)
			draw_rect(Rect2(Vector2(-86, -18), Vector2(28, 36)), Color(0.65, 0.12, 0.12, 0.95), true)
			draw_rect(Rect2(Vector2(58, -18), Vector2(28, 36)), Color(0.65, 0.12, 0.12, 0.95), true)
			draw_rect(Rect2(Vector2(-38, 18), Vector2(76, 20)), Color(0.42, 0.12, 0.12, 0.94), true)
		if is_core_exposed():
			draw_arc(Vector2.ZERO, 24.0 + exposed_alpha * 6.0, 0.0, TAU, 32, Color(1.0, 0.92, 0.64, 0.48 + exposed_alpha * 0.26), 3.0)
			draw_line(Vector2(-30.0, -8.0), Vector2(-16.0, -2.0), Color(1.0, 0.82, 0.46, 0.72), 2.0)
			draw_line(Vector2(-30.0, 8.0), Vector2(-16.0, 2.0), Color(1.0, 0.82, 0.46, 0.72), 2.0)
			draw_line(Vector2(30.0, -8.0), Vector2(16.0, -2.0), Color(1.0, 0.82, 0.46, 0.72), 2.0)
			draw_line(Vector2(30.0, 8.0), Vector2(16.0, 2.0), Color(1.0, 0.82, 0.46, 0.72), 2.0)
		draw_circle(Vector2.ZERO, 14.0 + impact_flash_timer * 16.0 + exposed_alpha * 4.0, Color(1.0, 0.88, 0.5, core_alpha))
		if fire_timer <= 0.36:
			_draw_boss_telegraph(ratio)
	else:
		match enemy_role:
			"sniper":
				var sniper_points := PackedVector2Array([
					Vector2(0, -20),
					Vector2(16, 10),
					Vector2(6, 14),
					Vector2(0, 10),
					Vector2(-6, 14),
					Vector2(-16, 10)
				])
				draw_colored_polygon(sniper_points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_rect(Rect2(Vector2(-4, -22), Vector2(8, 16)), Color(1.0, 0.86, 0.5), true)
				if fire_timer <= telegraph_window:
					_draw_target_telegraph(Color(1.0, 0.86, 0.48, 0.55), 1.8)
			"burst":
				var burst_points := PackedVector2Array([
					Vector2(0, -22),
					Vector2(18, 10),
					Vector2(0, 18),
					Vector2(-18, 10)
				])
				draw_colored_polygon(burst_points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_circle(Vector2(0, -2), 5.5, Color(1.0, 0.78, 0.46))
				if fire_timer <= telegraph_window:
					draw_arc(Vector2.ZERO, 25.0, PI * 0.28, PI * 0.72, 10, Color(1.0, 0.62, 0.42, 0.48), 2.0)
			"suppressor":
				var suppressor_points := PackedVector2Array([
					Vector2(0, -20),
					Vector2(22, -2),
					Vector2(16, 14),
					Vector2(-16, 14),
					Vector2(-22, -2)
				])
				draw_colored_polygon(suppressor_points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_rect(Rect2(Vector2(-22, -3), Vector2(44, 6)), Color(1.0, 0.82, 0.46), true)
				draw_rect(Rect2(Vector2(-12, 8), Vector2(24, 5)), Color(1.0, 0.58, 0.3), true)
				if fire_timer <= telegraph_window:
					for angle_offset in [-0.34, -0.17, 0.0, 0.17, 0.34]:
						var end_point := Vector2(angle_offset * 54.0, 72.0)
						draw_line(Vector2.ZERO, end_point, Color(1.0, 0.78, 0.4, 0.46), 2.0)
					draw_arc(Vector2.ZERO, 34.0, PI * 0.18, PI * 0.82, 16, Color(1.0, 0.76, 0.42, 0.42), 2.0)
			"sweeper":
				var sweeper_points := PackedVector2Array([
					Vector2(0, -16),
					Vector2(22, 4),
					Vector2(10, 16),
					Vector2(-10, 16),
					Vector2(-22, 4)
				])
				draw_colored_polygon(sweeper_points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_rect(Rect2(Vector2(-18, 2), Vector2(36, 6)), Color(1.0, 0.74, 0.38), true)
				if movement_pattern == "dash" and elapsed >= dash_delay * 0.6 and elapsed < dash_delay + 0.22:
					draw_line(Vector2(0, 18), Vector2(0, 42), Color(1.0, 0.68, 0.3, 0.4), 4.0)
			"anchor":
				var anchor_points := PackedVector2Array([
					Vector2(0, -20),
					Vector2(18, -4),
					Vector2(16, 14),
					Vector2(-16, 14),
					Vector2(-18, -4)
				])
				draw_colored_polygon(anchor_points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_rect(Rect2(Vector2(-16, -2), Vector2(32, 8)), Color(1.0, 0.82, 0.52), true)
				draw_rect(Rect2(Vector2(-8, 8), Vector2(16, 6)), Color(1.0, 0.54, 0.28), true)
				if fire_timer <= telegraph_window:
					draw_arc(Vector2.ZERO, 30.0, PI * 0.16, PI * 0.84, 14, Color(1.0, 0.68, 0.38, 0.5), 3.0)
			"pincer":
				var pincer_points := PackedVector2Array([
					Vector2(0, -18),
					Vector2(20, -2),
					Vector2(12, 16),
					Vector2(-12, 16),
					Vector2(-20, -2)
				])
				draw_colored_polygon(pincer_points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_rect(Rect2(Vector2(-18, -2), Vector2(36, 6)), Color(1.0, 0.84, 0.52), true)
				draw_line(Vector2(-10, 10), Vector2(-20, 20), Color(1.0, 0.66, 0.32, 0.92), 2.0)
				draw_line(Vector2(10, 10), Vector2(20, 20), Color(1.0, 0.66, 0.32, 0.92), 2.0)
				if fire_timer <= telegraph_window:
					_draw_pincer_telegraph(Color(1.0, 0.82, 0.48, 0.52), 2.0)
			"screener":
				var screener_points := PackedVector2Array([
					Vector2(0, -20),
					Vector2(22, -2),
					Vector2(18, 14),
					Vector2(-18, 14),
					Vector2(-22, -2)
				])
				draw_colored_polygon(screener_points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_rect(Rect2(Vector2(-20, -4), Vector2(40, 8)), Color(0.72, 0.92, 1.0), true)
				draw_rect(Rect2(Vector2(-10, 8), Vector2(20, 6)), Color(0.36, 0.8, 1.0), true)
				if fire_timer <= telegraph_window:
					draw_arc(Vector2.ZERO, 34.0, PI * 0.12, PI * 0.88, 16, Color(0.72, 0.92, 1.0, 0.54), 3.0)
			_:
				var points := PackedVector2Array([
					Vector2(0, -18),
					Vector2(14, 14),
					Vector2(0, 8),
					Vector2(-14, 14)
				])
				draw_colored_polygon(points, base_tint.lightened(impact_flash_timer * 0.8))
				draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.9, 0.62))


func _draw_target_telegraph(color: Color, width: float) -> void:
	var direction := _get_player_direction()
	var end_point := direction * 78.0
	draw_line(Vector2.ZERO, end_point, color, width)
	draw_circle(end_point, 4.0, Color(color.r, color.g, color.b, min(0.9, color.a + 0.2)))


func _draw_pincer_telegraph(color: Color, width: float) -> void:
	var base_direction := _get_player_direction()
	for horizontal_bias in [-0.26, 0.26]:
		var direction := (base_direction + Vector2(horizontal_bias, 0.0)).normalized()
		var end_point := direction * 84.0
		draw_line(Vector2.ZERO, end_point, color, width)
		draw_circle(end_point, 3.5, Color(color.r, color.g, color.b, min(0.88, color.a + 0.18)))


func _draw_boss_telegraph(ratio: float) -> void:
	var telegraph_alpha: float = 0.28 + (telegraph_window - min(fire_timer, telegraph_window)) * 0.75
	var left_origin := Vector2(-44.0, 24.0)
	var right_origin := Vector2(44.0, 24.0)
	draw_arc(Vector2.ZERO, 72.0, PI * 0.18, PI * 0.82, 20, Color(1.0, 0.64, 0.42, telegraph_alpha), 3.0)
	if ratio <= 0.66:
		var side_origins: Array[Vector2] = [left_origin, right_origin]
		for side_origin in side_origins:
			var direction: Vector2 = (_get_player_direction() + Vector2(side_origin.x * 0.0025, 0.0)).normalized()
			draw_line(side_origin, side_origin + direction * 110.0, Color(1.0, 0.84, 0.56, telegraph_alpha + 0.08), 2.0)
