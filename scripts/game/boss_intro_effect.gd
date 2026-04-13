extends Node2D

var duration := 1.1
var elapsed := 0.0
var frame_size := Vector2(320.0, 146.0)
var accent_color := Color(1.0, 0.78, 0.42, 0.92)


func configure(size_value: Vector2 = Vector2(320.0, 146.0), duration_value: float = 1.1, color_value: Color = Color(1.0, 0.78, 0.42, 0.92)):
	frame_size = size_value
	duration = duration_value
	accent_color = color_value
	return self


func _ready() -> void:
	z_index = 60


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var ratio := clampf(elapsed / duration, 0.0, 1.0)
	var fade_alpha := 1.0 - ratio
	var pulse := 0.72 + sin(ratio * TAU * 3.0) * 0.16
	var half_size := frame_size * 0.5
	var bracket := 26.0 + (1.0 - ratio) * 18.0
	var frame_color := Color(accent_color.r, accent_color.g, accent_color.b, accent_color.a * fade_alpha)
	var soft_color := Color(accent_color.r, accent_color.g, accent_color.b, 0.18 * fade_alpha)

	draw_rect(Rect2(-half_size, frame_size), soft_color, true)
	draw_rect(Rect2(-half_size, frame_size), Color(frame_color.r, frame_color.g, frame_color.b, 0.34 * fade_alpha), false, 2.0)

	_draw_corner(Vector2(-half_size.x, -half_size.y), Vector2.RIGHT, Vector2.DOWN, bracket, frame_color, pulse)
	_draw_corner(Vector2(half_size.x, -half_size.y), Vector2.LEFT, Vector2.DOWN, bracket, frame_color, pulse)
	_draw_corner(Vector2(-half_size.x, half_size.y), Vector2.RIGHT, Vector2.UP, bracket, frame_color, pulse)
	_draw_corner(Vector2(half_size.x, half_size.y), Vector2.LEFT, Vector2.UP, bracket, frame_color, pulse)

	var scan_y := lerpf(-half_size.y, half_size.y, ratio)
	draw_line(
		Vector2(-half_size.x, scan_y),
		Vector2(half_size.x, scan_y),
		Color(frame_color.r, frame_color.g, frame_color.b, 0.56 * fade_alpha),
		2.0
	)

	var center_radius := lerpf(18.0, 44.0, ratio)
	draw_arc(Vector2.ZERO, center_radius, 0.0, TAU, 28, Color(1.0, 0.92, 0.68, 0.68 * fade_alpha), 2.0)
	draw_arc(Vector2.ZERO, center_radius * 0.58, 0.0, TAU, 20, Color(1.0, 0.92, 0.68, 0.42 * fade_alpha), 1.0)


func _draw_corner(origin: Vector2, x_dir: Vector2, y_dir: Vector2, length: float, color: Color, pulse: float) -> void:
	var width := 3.0 * pulse
	draw_line(origin, origin + x_dir * length, color, width)
	draw_line(origin, origin + y_dir * length, color, width)
