extends Node2D

var lifetime := 0.14
var elapsed := 0.0
var effect_radius := 18.0
var effect_color := Color(1.0, 0.86, 0.56, 0.9)


func configure(radius_value: float = 18.0, color_value: Color = Color(1.0, 0.86, 0.56, 0.9)):
	effect_radius = radius_value
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
	var radius: float = lerpf(effect_radius * 0.3, effect_radius, ratio)
	var alpha: float = 1.0 - ratio
	draw_circle(Vector2.ZERO, radius, Color(effect_color.r, effect_color.g, effect_color.b, 0.16 * alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 18, Color(effect_color.r, effect_color.g, effect_color.b, 0.92 * alpha), 2.0)

