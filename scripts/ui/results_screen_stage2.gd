extends Control

var reveal_nodes: Array[CanvasItem] = []


func _ready() -> void:
	_build_ui()
	_play_reveal_sequence()
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
	background.color = Color(0.03, 0.04, 0.08)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow_top := ColorRect.new()
	glow_top.color = Color(0.22, 0.32, 0.52, 0.22)
	glow_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	glow_top.offset_bottom = 180.0
	add_child(glow_top)

	var glow_bottom := ColorRect.new()
	glow_bottom.color = Color(0.72, 0.34, 0.22, 0.12) if RunState.current_run.victory else Color(0.62, 0.18, 0.18, 0.14)
	glow_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	glow_bottom.offset_top = -220.0
	add_child(glow_bottom)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_top = -350
	panel.offset_right = 250
	panel.offset_bottom = 350
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	var hero_box := VBoxContainer.new()
	hero_box.add_theme_constant_override("separation", 6)
	column.add_child(hero_box)
	_register_reveal(hero_box)

	var title := Label.new()
	title.text = "STAGE CLEAR" if RunState.current_run.victory else "MISSION FAILED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	hero_box.add_child(title)

	var grade := Label.new()
	grade.text = "GRADE %s" % RunState.get_performance_grade()
	grade.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade.add_theme_font_size_override("font_size", 30)
	grade.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5) if RunState.current_run.victory else Color(1.0, 0.6, 0.48))
	hero_box.add_child(grade)

	var flavor := Label.new()
	flavor.text = RunState.get_result_flavor()
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor.add_theme_font_size_override("font_size", 18)
	hero_box.add_child(flavor)

	var tags := Label.new()
	tags.text = " / ".join(RunState.get_result_tags())
	tags.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tags.add_theme_font_size_override("font_size", 16)
	hero_box.add_child(tags)

	var stat_row := HBoxContainer.new()
	stat_row.add_theme_constant_override("separation", 10)
	column.add_child(stat_row)
	_register_reveal(stat_row)
	stat_row.add_child(_build_stat_card("FINAL SCORE", "%06d" % int(RunState.current_run.final_score)))
	stat_row.add_child(_build_stat_card("KILL RATE", "%.0f%%" % RunState.get_kill_rate()))
	stat_row.add_child(_build_stat_card("MAX FIRE", "Lv%d" % int(RunState.current_run.max_fire_level)))

	var route_panel := PanelContainer.new()
	column.add_child(route_panel)
	_register_reveal(route_panel)
	var route_margin := MarginContainer.new()
	route_margin.add_theme_constant_override("margin_left", 12)
	route_margin.add_theme_constant_override("margin_top", 10)
	route_margin.add_theme_constant_override("margin_right", 12)
	route_margin.add_theme_constant_override("margin_bottom", 10)
	route_panel.add_child(route_margin)
	var route_label := Label.new()
	route_label.text = "FIRE ROUTE  %s" % RunState.get_fire_route_text()
	route_label.add_theme_font_size_override("font_size", 20)
	route_margin.add_child(route_label)

	var insight_row := HBoxContainer.new()
	insight_row.add_theme_constant_override("separation", 10)
	column.add_child(insight_row)
	_register_reveal(insight_row)
	insight_row.add_child(_build_text_card("OFFENSE", RunState.get_offense_summary()))
	insight_row.add_child(_build_text_card("SURVIVAL", RunState.get_survival_summary()))
	insight_row.add_child(_build_text_card("RESOURCE", RunState.get_resource_summary()))

	var breakdown_panel := PanelContainer.new()
	column.add_child(breakdown_panel)
	_register_reveal(breakdown_panel)
	var breakdown_margin := MarginContainer.new()
	breakdown_margin.add_theme_constant_override("margin_left", 12)
	breakdown_margin.add_theme_constant_override("margin_top", 10)
	breakdown_margin.add_theme_constant_override("margin_right", 12)
	breakdown_margin.add_theme_constant_override("margin_bottom", 10)
	breakdown_panel.add_child(breakdown_margin)
	var breakdown_column := VBoxContainer.new()
	breakdown_column.add_theme_constant_override("separation", 8)
	breakdown_margin.add_child(breakdown_column)

	var score_breakdown := Label.new()
	score_breakdown.text = RunState.get_score_breakdown_text()
	score_breakdown.add_theme_font_size_override("font_size", 18)
	breakdown_column.add_child(score_breakdown)

	var detail := Label.new()
	detail.text = "Bombs Used: %d    Bombs Picked: %d\nPower Pickups: %d    Lives Lost: %d\nBoss Defeated: %s    Run Time: %.1f sec" % [
		RunState.current_run.bombs_used,
		RunState.current_run.bombs_collected,
		RunState.current_run.upgrades_collected,
		RunState.get_lives_lost(),
		"Yes" if RunState.current_run.boss_defeated else "No",
		RunState.current_run.duration_sec
	]
	detail.add_theme_font_size_override("font_size", 18)
	breakdown_column.add_child(detail)

	var analysis_panel := PanelContainer.new()
	column.add_child(analysis_panel)
	_register_reveal(analysis_panel)
	var analysis_margin := MarginContainer.new()
	analysis_margin.add_theme_constant_override("margin_left", 12)
	analysis_margin.add_theme_constant_override("margin_top", 10)
	analysis_margin.add_theme_constant_override("margin_right", 12)
	analysis_margin.add_theme_constant_override("margin_bottom", 10)
	analysis_panel.add_child(analysis_margin)
	var analysis := Label.new()
	analysis.text = "NEXT FOCUS  %s" % RunState.get_next_focus()
	analysis.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	analysis.add_theme_font_size_override("font_size", 18)
	analysis_margin.add_child(analysis)

	var footer_box := VBoxContainer.new()
	footer_box.add_theme_constant_override("separation", 10)
	column.add_child(footer_box)
	_register_reveal(footer_box)

	var footer := Label.new()
	footer.text = "R Retry    Esc Main Menu"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	footer_box.add_child(footer)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	footer_box.add_child(button_row)

	var again_button := Button.new()
	again_button.text = "Retry"
	again_button.custom_minimum_size = Vector2(170, 52)
	again_button.pressed.connect(func() -> void:
		RunState.start_game()
	)
	button_row.add_child(again_button)

	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(170, 48)
	menu_button.pressed.connect(func() -> void:
		RunState.go_to_menu()
	)
	button_row.add_child(menu_button)


func _build_stat_card(title_text: String, value_text: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 14)
	column.add_child(title)

	var value := Label.new()
	value.text = value_text
	value.add_theme_font_size_override("font_size", 24)
	column.add_child(value)
	return panel


func _build_text_card(title_text: String, body_text: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 14)
	column.add_child(title)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 16)
	column.add_child(body)
	return panel


func _register_reveal(item: CanvasItem) -> void:
	item.modulate.a = 0.0
	reveal_nodes.append(item)


func _play_reveal_sequence() -> void:
	if RunState.is_autoplay():
		for item in reveal_nodes:
			item.modulate.a = 1.0
		return

	for index in range(reveal_nodes.size()):
		var target := reveal_nodes[index]
		var delay := 0.08 * float(index)
		get_tree().create_timer(delay).timeout.connect(func() -> void:
			if not is_instance_valid(target):
				return
			var tween := create_tween()
			tween.tween_property(target, "modulate:a", 1.0, 0.22)
		)
