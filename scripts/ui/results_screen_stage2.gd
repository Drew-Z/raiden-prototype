extends Control


func _ready() -> void:
	_build_ui()
	if RunState.is_autoplay():
		get_tree().create_timer(0.4).timeout.connect(func() -> void:
			get_tree().quit()
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_game") and not event.is_echo():
		RunState.start_game()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		RunState.go_to_menu()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.04, 0.05, 0.1)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -220
	panel.offset_top = -320
	panel.offset_right = 220
	panel.offset_bottom = 320
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	var title := Label.new()
	title.text = "STAGE CLEAR" if RunState.current_run.victory else "MISSION FAILED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	column.add_child(title)

	var grade := Label.new()
	grade.text = "GRADE %s" % RunState.get_performance_grade()
	grade.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade.add_theme_font_size_override("font_size", 30)
	column.add_child(grade)

	var flavor := Label.new()
	flavor.text = RunState.get_result_flavor()
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor.add_theme_font_size_override("font_size", 18)
	column.add_child(flavor)

	var tags := Label.new()
	tags.text = " / ".join(RunState.get_result_tags())
	tags.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tags.add_theme_font_size_override("font_size", 16)
	column.add_child(tags)

	var summary := Label.new()
	summary.text = "Score: %06d\nKill Rate: %.0f%%\nMax Fire: Lv%d\nFire Route: %s" % [
		RunState.current_run.score,
		RunState.get_kill_rate(),
		RunState.current_run.max_fire_level,
		RunState.get_fire_route_text()
	]
	summary.add_theme_font_size_override("font_size", 22)
	column.add_child(summary)

	var detail := Label.new()
	detail.text = "Bombs Used: %d    Bombs Picked: %d\nPower Pickups: %d    Lives Lost: %d\nBoss Defeated: %s    Run Time: %.1f sec" % [
		RunState.current_run.bombs_used,
		RunState.current_run.bombs_collected,
		RunState.current_run.upgrades_collected,
		RunState.get_lives_lost(),
		"Yes" if RunState.current_run.boss_defeated else "No",
		RunState.current_run.duration_sec
	]
	detail.add_theme_font_size_override("font_size", 20)
	column.add_child(detail)

	var analysis := Label.new()
	analysis.text = "Run Focus: %s" % RunState.get_next_focus()
	analysis.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	analysis.add_theme_font_size_override("font_size", 18)
	column.add_child(analysis)

	var footer := Label.new()
	footer.text = "R Retry    Esc Main Menu"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	column.add_child(footer)

	var again_button := Button.new()
	again_button.text = "Retry"
	again_button.custom_minimum_size = Vector2(180, 52)
	again_button.pressed.connect(func() -> void:
		RunState.start_game()
	)
	column.add_child(again_button)

	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(180, 48)
	menu_button.pressed.connect(func() -> void:
		RunState.go_to_menu()
	)
	column.add_child(menu_button)
