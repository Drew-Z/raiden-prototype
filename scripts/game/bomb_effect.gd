extends Node2D
class_name BombEffect

var duration := 0.45
var elapsed := 0.0
var max_radius := 620.0
var ring_color := Color(1.0, 0.8, 0.48, 1.0)
var core_color := Color(0.4, 0.92, 1.0, 1.0)


func configure(radius_value: float = 620.0, duration_value: float = 0.45, ring_color_value: Color = Color(1.0, 0.8, 0.48, 1.0), core_color_value: Color = Color(0.4, 0.92, 1.0, 1.0)):
	max_radius = radius_value
	duration = duration_value
	ring_color = ring_color_value
	core_color = core_color_value
	return self


func _ready() -> void:
	z_index = 50


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
	if elapsed >= duration:
		queue_free()


func _draw() -> void:
	var ratio: float = clampf(elapsed / duration, 0.0, 1.0)
	var radius: float = lerpf(26.0, max_radius, ratio)
	var alpha: float = 0.26 * (1.0 - ratio)
	draw_circle(Vector2.ZERO, radius, Color(0.92, 0.97, 1.0, alpha))
	draw_arc(Vector2.ZERO, radius * 0.82, 0.0, TAU, 72, Color(ring_color.r, ring_color.g, ring_color.b, alpha * 2.4), 10.0)
	draw_arc(Vector2.ZERO, radius * 0.56, 0.0, TAU, 72, Color(core_color.r, core_color.g, core_color.b, alpha * 2.0), 7.0)
