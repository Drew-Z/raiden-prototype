extends Area2D
class_name StormSweep

signal finished

const LAYER_ENEMY_BULLET := 8

var screen_rect := Rect2(Vector2.ZERO, Vector2(540, 960))
var telegraph_duration := 0.95
var active_duration := 0.34
var sweep_half_height := 24.0
var timer := 0.0
var active := false
var warning_color := Color(0.98, 0.78, 0.4, 0.75)
var beam_color := Color(0.78, 0.92, 1.0, 0.92)
var flash_phase := 0.0
var collision_shape: CollisionShape2D


func _init() -> void:
	monitorable = true
	monitoring = true


func configure(strike_y: float, bounds: Rect2, telegraph_time: float = 0.95, active_time: float = 0.42) -> StormSweep:
	position = Vector2(bounds.size.x * 0.5, strike_y)
	screen_rect = bounds
	telegraph_duration = telegraph_time
	active_duration = active_time
	timer = telegraph_duration
	return self


func _ready() -> void:
	collision_layer = LAYER_ENEMY_BULLET
	collision_mask = 0
	add_to_group("hazards")
	collision_shape = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(screen_rect.size.x, sweep_half_height * 2.0)
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO
	collision_shape.disabled = true
	add_child(collision_shape)
	queue_redraw()


func _process(delta: float) -> void:
	timer -= delta
	flash_phase += delta
	if not active and timer <= 0.0:
		active = true
		timer = active_duration
		if is_instance_valid(collision_shape):
			collision_shape.disabled = false
	elif active and timer <= 0.0:
		finished.emit()
		queue_free()
	queue_redraw()


func _draw() -> void:
	var beam_rect := Rect2(
		Vector2(-screen_rect.size.x * 0.5, -sweep_half_height),
		Vector2(screen_rect.size.x, sweep_half_height * 2.0)
	)
	if not active:
		var pulse: float = 0.2 + abs(sin(flash_phase * 7.0)) * 0.24
		draw_rect(beam_rect, Color(warning_color.r, warning_color.g, warning_color.b, pulse), true)
		draw_line(Vector2(-screen_rect.size.x * 0.5, 0.0), Vector2(screen_rect.size.x * 0.5, 0.0), Color(1.0, 0.94, 0.72, 0.7), 2.0)
		draw_rect(
			Rect2(
				Vector2(-screen_rect.size.x * 0.5, -sweep_half_height - 6.0),
				Vector2(screen_rect.size.x, sweep_half_height * 2.0 + 12.0)
			),
			Color(0.88, 0.5, 0.18, 0.08 + pulse * 0.25),
			false,
			3.0
		)
	else:
		var flash: float = 0.74 + abs(sin(flash_phase * 18.0)) * 0.18
		draw_rect(beam_rect, Color(beam_color.r, beam_color.g, beam_color.b, flash), true)
		draw_line(Vector2(-screen_rect.size.x * 0.5, 0.0), Vector2(screen_rect.size.x * 0.5, 0.0), Color(1.0, 1.0, 1.0, 0.9), 5.0)
		draw_rect(
			Rect2(
				Vector2(-screen_rect.size.x * 0.5, -sweep_half_height - 10.0),
				Vector2(screen_rect.size.x, sweep_half_height * 2.0 + 20.0)
			),
			Color(0.7, 0.92, 1.0, 0.22),
			false,
			4.0
		)
