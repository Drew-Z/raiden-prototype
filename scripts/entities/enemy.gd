extends Area2D
class_name Enemy

const BulletScript := preload("res://scripts/game/bullet.gd")

signal spawn_bullet(bullet)
signal destroyed(enemy, by_player: bool)
signal escaped(enemy)

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
var screen_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var is_boss := false
var boss_name := ""
var target_y := 160.0
var boss_anchor_x := 270.0
var elapsed := 0.0
var entered_screen := false
var base_tint := Color(0.95, 0.33, 0.33)
var alive := true


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
	screen_rect = config.get("screen_rect", screen_rect)
	is_boss = config.get("is_boss", false)
	target_y = config.get("target_y", 160.0)
	boss_anchor_x = config.get("boss_anchor_x", position.x)
	boss_name = config.get("boss_name", "HX-1")
	bullet_speed = config.get("bullet_speed", 220.0)
	base_tint = config.get("tint", Color(0.95, 0.33, 0.33))
	return self


func _physics_process(delta: float) -> void:
	if not alive:
		return

	elapsed += delta
	fire_timer -= delta

	match movement_pattern:
		"straight":
			position += velocity * delta
		"sine":
			position.y += velocity.y * delta
			position.x = spawn_x + sin(elapsed * frequency + phase) * amplitude
		"angled":
			position += velocity * delta
		"boss":
			if position.y < target_y:
				position.y = min(target_y, position.y + 110.0 * delta)
			else:
				position.x = boss_anchor_x + sin(elapsed * frequency) * amplitude

	if screen_rect.has_point(position):
		entered_screen = true

	if fire_interval > 0.0 and fire_timer <= 0.0 and (entered_screen or is_boss):
		_fire()
		fire_timer = fire_interval

	if not is_boss and entered_screen and not screen_rect.grow(80.0).has_point(position):
		escaped.emit(self)
		queue_free()

	queue_redraw()


func _fire() -> void:
	if is_boss:
		for offset in [-0.42, -0.21, 0.0, 0.21, 0.42]:
			var direction := Vector2(offset, 1.0).normalized()
			var bullet = BulletScript.new().configure(position + Vector2(offset * 52.0, 36.0), direction * bullet_speed, 1, false, 6.0, Color(1.0, 0.45, 0.35), screen_rect)
			spawn_bullet.emit(bullet)
	else:
		var bullet = BulletScript.new().configure(position + Vector2(0, 18), Vector2(0, bullet_speed), 1, false, 5.0, Color(1.0, 0.5, 0.35), screen_rect)
		spawn_bullet.emit(bullet)


func apply_damage(amount: int, by_player: bool = true) -> void:
	if not alive:
		return
	health -= amount
	modulate = Color(1.0, 1.0, 1.0)
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
		draw_circle(Vector2.ZERO, 46.0, Color(0.35, 0.18, 0.18, 0.95))
		draw_rect(Rect2(Vector2(-52, -28), Vector2(104, 56)), base_tint, true)
		draw_rect(Rect2(Vector2(-22, -48), Vector2(44, 22)), Color(1.0, 0.78, 0.3, 0.95), true)
	else:
		var points := PackedVector2Array([
			Vector2(0, -18),
			Vector2(14, 14),
			Vector2(0, 8),
			Vector2(-14, 14)
		])
		draw_colored_polygon(points, base_tint)
		draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.9, 0.62))
