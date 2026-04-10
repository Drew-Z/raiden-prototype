extends Node2D

var lifetime := 0.32
var elapsed := 0.0
var effect_scale := 1.0
var effect_color := Color(1.0, 0.56, 0.34, 0.95)


func configure(scale_value: float = 1.0, color_value: Color = Color(1.0, 0.56, 0.34, 0.95)):
	effect_scale = scale_value
	effect_color = color_value
	return self


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var ratio: float = clampf(elapsed / lifetime, 0.0, 1.0)
	var outer_radius: float = lerpf(8.0, 30.0 * effect_scale, ratio)
	var inner_radius: float = lerpf(4.0, 16.0 * effect_scale, ratio)
	var alpha: float = 1.0 - ratio
	draw_circle(Vector2.ZERO, outer_radius, Color(effect_color.r, effect_color.g, effect_color.b, 0.22 * alpha))
	draw_circle(Vector2.ZERO, inner_radius, Color(1.0, 0.92, 0.7, 0.62 * alpha))
	for angle_step in range(6):
		var angle: float = TAU * float(angle_step) / 6.0
		var point := Vector2.RIGHT.rotated(angle) * outer_radius
		draw_line(Vector2.ZERO, point, Color(effect_color.r, effect_color.g, effect_color.b, 0.88 * alpha), 2.0)
