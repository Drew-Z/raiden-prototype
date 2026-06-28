extends Control


func _ready() -> void:
	_build_ui()
	if RunState.is_autoplay():
		call_deferred("_auto_start")


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.03, 0.04, 0.1)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var accent := ColorRect.new()
	accent.color = Color(0.08, 0.16, 0.28, 0.85)
	accent.set_anchors_preset(Control.PRESET_CENTER)
	accent.custom_minimum_size = Vector2(420, 420)
	accent.position = Vector2(60, 180)
	add_child(accent)

	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.offset_left = -180
	column.offset_top = -180
	column.offset_right = 180
	column.offset_bottom = 180
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 22)
	add_child(column)

	var title := Label.new()
	title.text = "RAIDEN PROTOTYPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Minimal playable vertical shooter prototype\nWaves, power-ups, bombs and a short boss loop"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	column.add_child(subtitle)

	var start_button := Button.new()
	start_button.text = "Start Game"
	start_button.custom_minimum_size = Vector2(220, 56)
	start_button.pressed.connect(func() -> void:
		RunState.start_game()
	)
	column.add_child(start_button)

	var hint := Label.new()
	hint.text = "Move: WASD / Arrows    Bomb: Space / Shift / X\nShooting is always-on auto fire"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	column.add_child(hint)


func _auto_start() -> void:
	RunState.start_game()
