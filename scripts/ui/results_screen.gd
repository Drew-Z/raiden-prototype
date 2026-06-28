extends Control


func _ready() -> void:
	_build_ui()
	if RunState.is_autoplay():
		get_tree().create_timer(0.4).timeout.connect(func() -> void:
			get_tree().quit()
		)


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.04, 0.05, 0.1)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -210
	panel.offset_top = -250
	panel.offset_right = 210
	panel.offset_bottom = 250
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

	var summary := Label.new()
	summary.text = "Score: %06d\nKill Rate: %.0f%%\nMax Fire: Lv%d\nFire Route: %s\nBombs Used: %d\nRun Time: %.1f sec" % [
		RunState.current_run.score,
		RunState.get_kill_rate(),
		RunState.current_run.max_fire_level,
		RunState.get_fire_route_text(),
		RunState.current_run.bombs_used,
		RunState.current_run.duration_sec
	]
	summary.add_theme_font_size_override("font_size", 24)
	column.add_child(summary)

	var detail := Label.new()
	detail.text = "Boss Defeated: %s\nPower Pickups: %d\nLives Left: %d" % [
		"Yes" if RunState.current_run.boss_defeated else "No",
		RunState.current_run.upgrades_collected,
		max(RunState.current_run.player_lives, 0)
	]
	detail.add_theme_font_size_override("font_size", 22)
	column.add_child(detail)

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
