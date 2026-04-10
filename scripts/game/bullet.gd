extends Area2D
class_name Bullet

const LAYER_PLAYER := 1
const LAYER_PLAYER_BULLET := 2
const LAYER_ENEMY := 4
const LAYER_ENEMY_BULLET := 8

var velocity := Vector2.ZERO
var damage := 1
var friendly := true
var radius := 5.0
var tint := Color(0.4, 0.95, 1.0)
var screen_rect := Rect2(Vector2.ZERO, Vector2(540, 960))


func _init() -> void:
	monitorable = true
	monitoring = true


func _ready() -> void:
	add_to_group("projectiles")
	if friendly:
		add_to_group("player_projectiles")
		collision_layer = LAYER_PLAYER_BULLET
		collision_mask = LAYER_ENEMY
	else:
		add_to_group("enemy_projectiles")
		collision_layer = LAYER_ENEMY_BULLET
		collision_mask = LAYER_PLAYER

	if get_child_count() == 0:
		var collision := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = radius
		collision.shape = shape
		add_child(collision)

	queue_redraw()


func _physics_process(delta: float) -> void:
	position += velocity * delta
	if not screen_rect.grow(80.0).has_point(position):
		queue_free()


func configure(start_position: Vector2, bullet_velocity: Vector2, bullet_damage: int, is_friendly: bool, bullet_radius: float, bullet_tint: Color, bounds: Rect2) -> Bullet:
	position = start_position
	velocity = bullet_velocity
	damage = bullet_damage
	friendly = is_friendly
	radius = bullet_radius
	tint = bullet_tint
	screen_rect = bounds
	return self


func pop() -> void:
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, tint)
