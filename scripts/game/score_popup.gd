extends Node2D

var lifetime := 0.72
var elapsed := 0.0
var text := "+100"
var text_color := Color(1.0, 0.9, 0.62, 1.0)
var rise_velocity := Vector2(0.0, -34.0)
var label_scale := 1.0


func configure(text_value: String, color_value: Color = Color(1.0, 0.9, 0.62, 1.0), scale_value: float = 1.0):
	text = text_value
	text_color = color_value
	label_scale = scale_value
	return self


func _process(delta: float) -> void:
	elapsed += delta
	position += rise_velocity * delta
	if elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var ratio: float = clampf(elapsed / lifetime, 0.0, 1.0)
	var alpha: float = 1.0 - ratio
	var pulse_scale: float = 1.0 + sin(ratio * PI) * 0.08
	var font := ThemeDB.fallback_font
	var font_size := int(round(24.0 * label_scale * pulse_scale))
	var shadow_color := Color(0.02, 0.04, 0.08, 0.8 * alpha)
	var draw_color := Color(text_color.r, text_color.g, text_color.b, alpha)
	var origin := Vector2(-48.0 * label_scale, 0.0)
	draw_string(font, origin + Vector2(2.0, 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, shadow_color)
	draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, draw_color)
