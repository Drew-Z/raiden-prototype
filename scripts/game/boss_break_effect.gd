extends Node2D

var duration := 0.62
var elapsed := 0.0
var max_radius := 220.0
var accent_color := Color(1.0, 0.86, 0.52, 0.96)


func configure(radius_value: float = 220.0, duration_value: float = 0.62, color_value: Color = Color(1.0, 0.86, 0.52, 0.96)):
	max_radius = radius_value
	duration = duration_value
	accent_color = color_value
	return self


func _ready() -> void:
	z_index = 58


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var ratio := clampf(elapsed / duration, 0.0, 1.0)
	var alpha := 1.0 - ratio
	var outer_radius := lerpf(34.0, max_radius, ratio)
	var inner_radius := lerpf(8.0, max_radius * 0.42, ratio)
	draw_circle(Vector2.ZERO, outer_radius, Color(accent_color.r, accent_color.g, accent_color.b, 0.08 * alpha))
	draw_arc(Vector2.ZERO, outer_radius, 0.0, TAU, 56, Color(accent_color.r, accent_color.g, accent_color.b, 0.66 * alpha), 8.0)
	draw_arc(Vector2.ZERO, inner_radius, 0.0, TAU, 40, Color(1.0, 0.96, 0.78, 0.58 * alpha), 4.0)
	for ray_index in range(10):
		var angle := TAU * float(ray_index) / 10.0 + ratio * 0.42
		var ray_start := Vector2.RIGHT.rotated(angle) * inner_radius * 0.6
		var ray_end := Vector2.RIGHT.rotated(angle) * outer_radius * 1.04
		draw_line(ray_start, ray_end, Color(accent_color.r, accent_color.g, accent_color.b, 0.7 * alpha), 2.4)
