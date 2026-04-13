extends Control

var reveal_nodes: Array[CanvasItem] = []


func _ready() -> void:
	_build_ui()
	_play_reveal_sequence()
	if RunState.is_autoplay():
		get_tree().create_timer(0.5).timeout.connect(func() -> void:
			RunState.start_next_chapter_stage()
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		RunState.start_next_chapter_stage()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		RunState.go_to_menu()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.02, 0.03, 0.06)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var top_glow := ColorRect.new()
	top_glow.color = Color(0.14, 0.22, 0.36, 0.38)
	top_glow.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_glow.offset_bottom = 220.0
	add_child(top_glow)

	var bottom_glow := ColorRect.new()
	bottom_glow.color = Color(0.1, 0.16, 0.26, 0.22)
	bottom_glow.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_glow.offset_top = -260.0
	add_child(bottom_glow)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -236
	panel.offset_top = -340
	panel.offset_right = 236
	panel.offset_bottom = 340
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

	var next_meta := RunState.get_next_stage_meta()

	var title := Label.new()
	title.text = "CHAPTER BRIEFING"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	hero_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "%s" % String(next_meta.get("name", "NEXT STAGE"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	hero_box.add_child(subtitle)

	var tagline := Label.new()
	tagline.text = String(next_meta.get("tagline", "Proceed to the next combat zone."))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tagline.add_theme_font_size_override("font_size", 18)
	hero_box.add_child(tagline)

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
	route_label.text = "ROUTE CARRYOVER\n%s\n%s" % [
		RunState.get_chapter_transition_text(),
		RunState.get_chapter_carry_summary()
	]
	route_label.add_theme_font_size_override("font_size", 20)
	route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_margin.add_child(route_label)

	var timeline_panel := PanelContainer.new()
	column.add_child(timeline_panel)
	_register_reveal(timeline_panel)
	var timeline_margin := MarginContainer.new()
	timeline_margin.add_theme_constant_override("margin_left", 12)
	timeline_margin.add_theme_constant_override("margin_top", 10)
	timeline_margin.add_theme_constant_override("margin_right", 12)
	timeline_margin.add_theme_constant_override("margin_bottom", 10)
	timeline_panel.add_child(timeline_margin)
	var timeline_label := Label.new()
	timeline_label.text = "CHAPTER TIMELINE\n%s" % RunState.get_chapter_stage_breakdown_text()
	timeline_label.add_theme_font_size_override("font_size", 18)
	timeline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	timeline_margin.add_child(timeline_label)

	var mission_panel := PanelContainer.new()
	column.add_child(mission_panel)
	_register_reveal(mission_panel)
	var mission_margin := MarginContainer.new()
	mission_margin.add_theme_constant_override("margin_left", 12)
	mission_margin.add_theme_constant_override("margin_top", 10)
	mission_margin.add_theme_constant_override("margin_right", 12)
	mission_margin.add_theme_constant_override("margin_bottom", 10)
	mission_panel.add_child(mission_margin)
	var mission_label := Label.new()
	mission_label.text = "MISSION BRIEF\n%s" % RunState.get_chapter_transition_brief()
	mission_label.add_theme_font_size_override("font_size", 18)
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_margin.add_child(mission_label)

	var footer_box := VBoxContainer.new()
	footer_box.add_theme_constant_override("separation", 10)
	column.add_child(footer_box)
	_register_reveal(footer_box)

	var footer := Label.new()
	footer.text = "Enter Deploy    Esc Main Menu"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	footer_box.add_child(footer)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	footer_box.add_child(button_row)

	var deploy_button := Button.new()
	deploy_button.text = "Deploy"
	deploy_button.custom_minimum_size = Vector2(180, 52)
	deploy_button.pressed.connect(func() -> void:
		RunState.start_next_chapter_stage()
	)
	button_row.add_child(deploy_button)

	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(180, 48)
	menu_button.pressed.connect(func() -> void:
		RunState.go_to_menu()
	)
	button_row.add_child(menu_button)


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
