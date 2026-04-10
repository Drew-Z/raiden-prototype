extends Area2D
class_name Pickup

const LAYER_PLAYER := 1
const LAYER_PICKUP := 16

signal collected

var fall_speed := 145.0
var drift := 0.0
var screen_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var pulse := 0.0


func _init() -> void:
	monitoring = true
	monitorable = true
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 11.0
	collision.shape = shape
	add_child(collision)


func _ready() -> void:
	collision_layer = LAYER_PICKUP
	collision_mask = LAYER_PLAYER
	queue_redraw()


func configure(start_position: Vector2, bounds: Rect2):
	position = start_position
	screen_rect = bounds
	drift = randf_range(-28.0, 28.0)
	return self


func _physics_process(delta: float) -> void:
	pulse += delta
	position.y += fall_speed * delta
	position.x += sin(pulse * 2.0) * drift * delta
	queue_redraw()

	if not screen_rect.grow(60.0).has_point(position):
		queue_free()


func collect() -> void:
	collected.emit()
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(1.0, 0.86, 0.24, 0.95))
	draw_circle(Vector2.ZERO, 7.0 + sin(pulse * 4.0), Color(1.0, 1.0, 0.82, 0.85))
