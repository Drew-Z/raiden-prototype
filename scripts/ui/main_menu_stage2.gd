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

	var stripe := ColorRect.new()
	stripe.color = Color(0.08, 0.16, 0.28, 0.92)
	stripe.set_anchors_preset(Control.PRESET_TOP_WIDE)
	stripe.offset_top = 90.0
	stripe.offset_bottom = 290.0
	add_child(stripe)

	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.offset_left = -200
	column.offset_top = -280
	column.offset_right = 200
	column.offset_bottom = 260
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 18)
	add_child(column)

	var title := Label.new()
	title.text = "RAIDEN PROTOTYPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	column.add_child(title)

	var tag := Label.new()
	tag.text = "PHASE 2 SHOWCASE BUILD"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 24)
	column.add_child(tag)

	var summary := Label.new()
	summary.text = "Clearer pacing, stronger fire growth,\nbetter bomb presence and a heavier boss finish."
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_theme_font_size_override("font_size", 22)
	column.add_child(summary)

	var start_button := Button.new()
	start_button.text = "Start Sortie"
	start_button.custom_minimum_size = Vector2(240, 58)
	start_button.pressed.connect(func() -> void:
		RunState.start_game()
	)
	column.add_child(start_button)

	var features := Label.new()
	features.text = "New in this build:\n- Stronger early / mid / late rhythm\n- Clearer fire growth to Lv5\n- Bomb supply before the boss\n- Pause, restart and menu flow"
	features.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	features.add_theme_font_size_override("font_size", 18)
	column.add_child(features)

	if RunState.current_run.duration_sec > 0.0:
		var last_sortie := Label.new()
		last_sortie.text = "Last Sortie:\nGrade %s   Final %06d\nKill %.0f%%   Max Fire Lv%d" % [
			RunState.get_performance_grade(),
			RunState.current_run.final_score,
			RunState.get_kill_rate(),
			RunState.current_run.max_fire_level
		]
		last_sortie.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		last_sortie.add_theme_font_size_override("font_size", 18)
		column.add_child(last_sortie)

	var hint := Label.new()
	hint.text = "Move: WASD / Arrows\nBomb: Space / Shift / X\nPause: Esc / P    Restart: R"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	column.add_child(hint)


func _auto_start() -> void:
	RunState.start_game()
