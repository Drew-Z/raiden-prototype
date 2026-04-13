extends Area2D
class_name Pickup

const LAYER_PLAYER := 1
const LAYER_PICKUP := 16

signal collected(kind: String)

var fall_speed := 145.0
var drift := 0.0
var screen_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var pulse := 0.0
var pickup_type := "power"
var collected_flash := 0.0


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


func configure(start_position: Vector2, bounds: Rect2, kind: String = "power"):
	position = start_position
	screen_rect = bounds
	drift = randf_range(-28.0, 28.0)
	pickup_type = kind
	return self


func _physics_process(delta: float) -> void:
	pulse += delta
	collected_flash = max(collected_flash - delta, 0.0)
	var velocity := Vector2(sin(pulse * 2.0) * drift, fall_speed)
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		var to_player: Vector2 = player.position - position
		if to_player.length() < 140.0:
			velocity += to_player.normalized() * 220.0
	position += velocity * delta
	queue_redraw()

	if not screen_rect.grow(60.0).has_point(position):
		queue_free()


func collect() -> void:
	collected_flash = 0.18
	collected.emit(pickup_type)
	queue_free()


func _draw() -> void:
	if pickup_type == "bomb":
		draw_circle(Vector2.ZERO, 18.0 + sin(pulse * 5.0) * 1.5 + collected_flash * 12.0, Color(1.0, 0.54, 0.3, 0.12 + collected_flash * 0.2))
		draw_circle(Vector2.ZERO, 13.0, Color(1.0, 0.38, 0.24, 0.96))
		draw_rect(Rect2(Vector2(-4.0, -8.0), Vector2(8.0, 16.0)), Color(1.0, 0.92, 0.72, 0.92), true)
		draw_rect(Rect2(Vector2(-8.0, -4.0), Vector2(16.0, 8.0)), Color(1.0, 0.92, 0.72, 0.92), true)
		draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 18, Color(1.0, 0.9, 0.7, 0.44), 2.0)
	else:
		draw_circle(Vector2.ZERO, 17.0 + sin(pulse * 4.0) * 1.2 + collected_flash * 12.0, Color(1.0, 0.9, 0.32, 0.12 + collected_flash * 0.2))
		draw_circle(Vector2.ZERO, 12.0, Color(1.0, 0.86, 0.24, 0.95))
		draw_circle(Vector2.ZERO, 7.0 + sin(pulse * 4.0), Color(1.0, 1.0, 0.82, 0.85))
		draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 18, Color(1.0, 1.0, 0.82, 0.36), 2.0)
