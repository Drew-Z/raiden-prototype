extends Control

var reveal_nodes: Array[CanvasItem] = []
var top_bar: ColorRect
var bottom_bar: ColorRect
var pulse_glow: ColorRect
var ending_overlay: CanvasItem


func _ready() -> void:
	_build_ui()
	_play_intro_motion()
	_play_reveal_sequence()
	_play_ending_overlay()
	if RunState.is_autoplay():
		get_tree().create_timer(0.9).timeout.connect(func() -> void:
			get_tree().quit()
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		RunState.go_to_menu()
	elif event.is_action_pressed("restart_game") and not event.is_echo():
		RunState.start_chapter()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		RunState.go_to_menu()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.02, 0.025, 0.05)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	pulse_glow = ColorRect.new()
	pulse_glow.color = Color(0.84, 0.68, 0.28, 0.08)
	pulse_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(pulse_glow)

	for index in range(6):
		var stripe := ColorRect.new()
		stripe.color = Color(1.0, 0.82, 0.46, 0.045 if index % 2 == 0 else 0.02)
		stripe.anchor_left = 0.0
		stripe.anchor_right = 1.0
		stripe.offset_top = 132.0 + float(index) * 94.0
		stripe.offset_bottom = stripe.offset_top + 2.0
		add_child(stripe)

	top_bar = ColorRect.new()
	top_bar.color = Color(0.0, 0.0, 0.0, 0.9)
	top_bar.anchor_right = 1.0
	add_child(top_bar)

	bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.0, 0.0, 0.0, 0.9)
	bottom_bar.anchor_top = 1.0
	bottom_bar.anchor_right = 1.0
	bottom_bar.anchor_bottom = 1.0
	add_child(bottom_bar)

	var frame := MarginContainer.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 56)
	frame.add_theme_constant_override("margin_top", 78)
	frame.add_theme_constant_override("margin_right", 56)
	frame.add_theme_constant_override("margin_bottom", 76)
	add_child(frame)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	frame.add_child(root)

	var hero := VBoxContainer.new()
	hero.add_theme_constant_override("separation", 4)
	root.add_child(hero)
	_register_reveal(hero)

	var status := Label.new()
	status.text = "CHAPTER DEBRIEF // ROUTE SECURED"
	status.add_theme_font_size_override("font_size", 18)
	status.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	hero.add_child(status)

	var title := Label.new()
	title.text = "CHAPTER COMPLETE"
	title.add_theme_font_size_override("font_size", 42)
	hero.add_child(title)

	var headline := Label.new()
	headline.text = RunState.get_chapter_outro_headline()
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	headline.add_theme_font_size_override("font_size", 20)
	hero.add_child(headline)

	var timeline_row := HBoxContainer.new()
	timeline_row.add_theme_constant_override("separation", 12)
	root.add_child(timeline_row)
	_register_reveal(timeline_row)
	for card_data in RunState.get_chapter_timeline():
		timeline_row.add_child(_build_stage_card(card_data))

	var summary_row := HBoxContainer.new()
	summary_row.add_theme_constant_override("separation", 12)
	root.add_child(summary_row)
	_register_reveal(summary_row)

	summary_row.add_child(_build_stat_card("CHAPTER GRADE", RunState.get_chapter_grade()))
	summary_row.add_child(_build_stat_card("TOTAL SCORE", "%06d" % int(RunState.chapter_state.get("total_score", 0))))
	summary_row.add_child(_build_stat_card("CHAPTER KILL", "%.0f%%" % RunState.get_chapter_kill_rate()))
	summary_row.add_child(_build_stat_card("HIGH FIRE", "Lv%d" % int(RunState.chapter_state.get("highest_fire", 1))))

	var route_panel := _build_panel(
		"ROUTE SUMMARY",
		"%s\n\n%s" % [
			RunState.get_chapter_stage_breakdown_text(),
			RunState.get_chapter_clear_summary()
		]
	)
	root.add_child(route_panel)
	_register_reveal(route_panel)

	var split_row := HBoxContainer.new()
	split_row.add_theme_constant_override("separation", 16)
	root.add_child(split_row)
	_register_reveal(split_row)

	split_row.add_child(_build_panel("EPILOGUE", RunState.get_chapter_epilogue()))
	split_row.add_child(_build_panel("NEXT DIRECTIVE", RunState.get_chapter_outro_directive()))

	var footer_row := HBoxContainer.new()
	footer_row.alignment = BoxContainer.ALIGNMENT_END
	footer_row.add_theme_constant_override("separation", 14)
	root.add_child(footer_row)
	_register_reveal(footer_row)

	var footer := Label.new()
	footer.text = "Enter Main Menu    R Retry Chapter    Esc Main Menu"
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	footer_row.add_child(footer)

	var retry_button := Button.new()
	retry_button.text = "Retry Chapter"
	retry_button.custom_minimum_size = Vector2(190, 52)
	retry_button.pressed.connect(func() -> void:
		RunState.start_chapter()
	)
	footer_row.add_child(retry_button)

	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(170, 48)
	menu_button.pressed.connect(func() -> void:
		RunState.go_to_menu()
	)
	footer_row.add_child(menu_button)

	ending_overlay = _build_ending_overlay()
	add_child(ending_overlay)


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


func _build_panel(title_text: String, body_text: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	column.add_child(title)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 18)
	column.add_child(body)

	return panel


func _build_stage_card(card_data: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)

	var title := Label.new()
	title.text = String(card_data.get("label", "STAGE"))
	title.add_theme_font_size_override("font_size", 16)
	column.add_child(title)

	var status := Label.new()
	if bool(card_data.get("completed", false)):
		status.text = "CLEAR  GRADE %s" % String(card_data.get("grade", "--"))
		status.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	elif bool(card_data.get("active", false)):
		status.text = "ACTIVE"
		status.add_theme_color_override("font_color", Color(0.82, 0.94, 1.0))
	else:
		status.text = "PENDING"
		status.add_theme_color_override("font_color", Color(0.7, 0.74, 0.8))
	status.add_theme_font_size_override("font_size", 15)
	column.add_child(status)

	var summary := Label.new()
	summary.text = String(card_data.get("summary", ""))
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 14)
	column.add_child(summary)

	return panel


func _build_ending_overlay() -> CanvasItem:
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.0)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 6)
	panel.modulate.a = 0.0
	center.add_child(panel)

	var status := Label.new()
	status.text = "ENDING // STORM FRONT SECURED"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 20)
	status.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	panel.add_child(status)

	var title := Label.new()
	title.text = "CHAPTER ROUTE LOCKED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.text = RunState.get_chapter_outro_headline()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.custom_minimum_size = Vector2(620, 0)
	subtitle.add_theme_font_size_override("font_size", 20)
	panel.add_child(subtitle)

	overlay.set_meta("backdrop", backdrop)
	overlay.set_meta("panel", panel)
	return overlay


func _register_reveal(item: CanvasItem) -> void:
	item.modulate.a = 0.0
	reveal_nodes.append(item)


func _play_intro_motion() -> void:
	if RunState.is_autoplay():
		top_bar.offset_bottom = 52.0
		bottom_bar.offset_top = -52.0
		pulse_glow.color = Color(0.84, 0.68, 0.28, 0.14)
		return

	var bar_tween := create_tween()
	bar_tween.tween_property(top_bar, "offset_bottom", 52.0, 0.28)
	bar_tween.parallel().tween_property(bottom_bar, "offset_top", -52.0, 0.28)

	var pulse_tween := create_tween().set_loops()
	pulse_tween.tween_property(pulse_glow, "color:a", 0.16, 0.45)
	pulse_tween.tween_property(pulse_glow, "color:a", 0.06, 0.6)


func _play_ending_overlay() -> void:
	if not is_instance_valid(ending_overlay):
		return
	var backdrop: ColorRect = ending_overlay.get_meta("backdrop")
	var panel: CanvasItem = ending_overlay.get_meta("panel")
	if RunState.is_autoplay():
		backdrop.color.a = 0.18
		panel.modulate.a = 1.0
		return

	var tween := create_tween()
	tween.tween_property(backdrop, "color:a", 0.42, 0.22)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.22)
	tween.tween_interval(0.55)
	tween.tween_property(panel, "modulate:a", 0.0, 0.24)
	tween.parallel().tween_property(backdrop, "color:a", 0.0, 0.24)


func _play_reveal_sequence() -> void:
	if RunState.is_autoplay():
		for item in reveal_nodes:
			item.modulate.a = 1.0
		return

	for index in range(reveal_nodes.size()):
		var target := reveal_nodes[index]
		var delay := 0.1 * float(index)
		get_tree().create_timer(0.18 + delay).timeout.connect(func() -> void:
			if not is_instance_valid(target):
				return
			var tween := create_tween()
			tween.tween_property(target, "modulate:a", 1.0, 0.24)
		)
