extends RefCounted
class_name UiButtonStyle


static func apply(button: Button, accent: Color, primary: bool = false) -> void:
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var font_normal := Color(0.98, 0.98, 1.0) if primary else Color(0.96, 0.97, 1.0)
	var font_disabled := Color(0.68, 0.7, 0.76)
	var border := accent.lightened(0.18)
	var normal_fill := accent.darkened(0.12) if primary else Color(0.11, 0.13, 0.18, 0.94)
	var hover_fill := accent.lightened(0.1) if primary else Color(
		clampf(accent.r * 0.28 + 0.1, 0.0, 1.0),
		clampf(accent.g * 0.28 + 0.11, 0.0, 1.0),
		clampf(accent.b * 0.28 + 0.14, 0.0, 1.0),
		0.98
	)
	var pressed_fill := accent.darkened(0.28) if primary else Color(
		clampf(accent.r * 0.2 + 0.08, 0.0, 1.0),
		clampf(accent.g * 0.2 + 0.09, 0.0, 1.0),
		clampf(accent.b * 0.2 + 0.12, 0.0, 1.0),
		0.98
	)
	var disabled_fill := Color(0.12, 0.13, 0.16, 0.74)

	button.add_theme_stylebox_override("normal", _build_style(normal_fill, border, 1, 12))
	button.add_theme_stylebox_override("hover", _build_style(hover_fill, border.lightened(0.12), 2, 14))
	button.add_theme_stylebox_override("pressed", _build_style(pressed_fill, border.darkened(0.16), 2, 10))
	button.add_theme_stylebox_override("focus", _build_style(hover_fill, accent.lightened(0.28), 2, 14))
	button.add_theme_stylebox_override("disabled", _build_style(disabled_fill, Color(0.24, 0.26, 0.3, 0.7), 1, 8))

	button.add_theme_color_override("font_color", font_normal)
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_disabled_color", font_disabled)
	button.add_theme_constant_override("outline_size", 0)


static func _build_style(fill: Color, border: Color, border_width: int, shadow_size: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0.0, 4.0)
	return style
