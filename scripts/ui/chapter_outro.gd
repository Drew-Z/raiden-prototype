extends Control

var reveal_nodes: Array[CanvasItem] = []
var top_bar: ColorRect
var bottom_bar: ColorRect
var pulse_glow: ColorRect
var ending_overlay: CanvasItem
var scroll_container: ScrollContainer


func _ready() -> void:
	_build_ui()
	_play_intro_motion()
	_play_reveal_sequence()
	_play_ending_overlay()
	if RunState.is_autoplay():
		get_tree().create_timer(0.9).timeout.connect(func() -> void:
			get_tree().quit()
		)


func _input(event: InputEvent) -> void:
	if _handle_wheel_scroll(event):
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		RunState.go_to_menu()
	elif event.is_action_pressed("restart_game") and not event.is_echo():
		RunState.start_chapter()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		RunState.go_to_menu()


func _build_ui() -> void:
	var viewport_size := get_viewport_rect().size
	var narrow_layout := viewport_size.x <= 560.0

	var background := ColorRect.new()
	background.color = Color(0.02, 0.025, 0.05)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	pulse_glow = ColorRect.new()
	pulse_glow.color = Color(0.84, 0.68, 0.28, 0.08)
	pulse_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	pulse_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pulse_glow)

	for index in range(6):
		var stripe := ColorRect.new()
		stripe.color = Color(1.0, 0.82, 0.46, 0.045 if index % 2 == 0 else 0.02)
		stripe.anchor_left = 0.0
		stripe.anchor_right = 1.0
		stripe.offset_top = 132.0 + float(index) * 94.0
		stripe.offset_bottom = stripe.offset_top + 2.0
		stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(stripe)

	top_bar = ColorRect.new()
	top_bar.color = Color(0.0, 0.0, 0.0, 0.9)
	top_bar.anchor_right = 1.0
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_bar)

	bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.0, 0.0, 0.0, 0.9)
	bottom_bar.anchor_top = 1.0
	bottom_bar.anchor_right = 1.0
	bottom_bar.anchor_bottom = 1.0
	bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_bar)

	var frame := MarginContainer.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 16 if narrow_layout else 56)
	frame.add_theme_constant_override("margin_top", 24 if narrow_layout else 78)
	frame.add_theme_constant_override("margin_right", 16 if narrow_layout else 56)
	frame.add_theme_constant_override("margin_bottom", 20 if narrow_layout else 76)
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(frame)

	var root := VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 14 if narrow_layout else 16)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	frame.add_child(root)

	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll_container)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.custom_minimum_size = Vector2(maxf(0.0, viewport_size.x - (32.0 if narrow_layout else 112.0)), 0.0)
	content.add_theme_constant_override("separation", 14 if narrow_layout else 16)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll_container.add_child(content)

	var hero := VBoxContainer.new()
	hero.add_theme_constant_override("separation", 4)
	content.add_child(hero)
	_register_reveal(hero)

	var status := Label.new()
	status.text = _t("章节总结 // 路线已完成", "CHAPTER DEBRIEF // ROUTE SECURED")
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if narrow_layout else HORIZONTAL_ALIGNMENT_LEFT
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 18)
	_mark_read_only(status)
	status.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	hero.add_child(status)

	var title := Label.new()
	title.text = _t("章节完成", "CHAPTER COMPLETE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if narrow_layout else HORIZONTAL_ALIGNMENT_LEFT
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 34 if narrow_layout else 42)
	_mark_read_only(title)
	hero.add_child(title)

	var headline := Label.new()
	headline.text = RunState.get_chapter_outro_headline()
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if narrow_layout else HORIZONTAL_ALIGNMENT_LEFT
	headline.add_theme_font_size_override("font_size", 18 if narrow_layout else 20)
	_mark_read_only(headline)
	hero.add_child(headline)

	var timeline_row := GridContainer.new()
	timeline_row.columns = 1 if narrow_layout else 2
	timeline_row.add_theme_constant_override("h_separation", 12)
	timeline_row.add_theme_constant_override("v_separation", 12)
	content.add_child(timeline_row)
	_register_reveal(timeline_row)
	for card_data in RunState.get_chapter_timeline():
		timeline_row.add_child(_build_stage_card(card_data))

	var summary_row := GridContainer.new()
	summary_row.columns = 1 if narrow_layout else 4
	summary_row.add_theme_constant_override("h_separation", 12)
	summary_row.add_theme_constant_override("v_separation", 12)
	content.add_child(summary_row)
	_register_reveal(summary_row)

	summary_row.add_child(_build_stat_card(_t("章节评级", "CHAPTER GRADE"), RunState.get_chapter_grade()))
	summary_row.add_child(_build_stat_card(_t("总得分", "TOTAL SCORE"), "%06d" % int(RunState.chapter_state.get("total_score", 0))))
	summary_row.add_child(_build_stat_card(_t("章节击破", "CHAPTER KILL"), "%.0f%%" % RunState.get_chapter_kill_rate()))
	summary_row.add_child(_build_stat_card(_t("最高火力", "HIGH FIRE"), "Lv%d" % int(RunState.chapter_state.get("highest_fire", 1))))

	var route_panel := _build_panel(
		_t("路线总结", "ROUTE SUMMARY"),
		"%s\n\n%s" % [
			RunState.get_chapter_stage_breakdown_text(),
			RunState.get_chapter_clear_summary()
		]
	)
	content.add_child(route_panel)
	_register_reveal(route_panel)

	var split_row := GridContainer.new()
	split_row.columns = 1 if narrow_layout else 2
	split_row.add_theme_constant_override("h_separation", 16)
	split_row.add_theme_constant_override("v_separation", 16)
	content.add_child(split_row)
	_register_reveal(split_row)

	split_row.add_child(_build_panel(_t("尾声", "EPILOGUE"), RunState.get_chapter_epilogue()))
	split_row.add_child(_build_panel(_t("下一步指令", "NEXT DIRECTIVE"), RunState.get_chapter_outro_directive()))

	var package_row := GridContainer.new()
	package_row.columns = 1 if narrow_layout else 2
	package_row.add_theme_constant_override("h_separation", 16)
	package_row.add_theme_constant_override("v_separation", 16)
	content.add_child(package_row)
	_register_reveal(package_row)

	package_row.add_child(_build_panel(_t("最终封装", "FINAL PACKAGE"), RunState.get_final_package_summary()))
	package_row.add_child(_build_panel(_t("下一步", "NEXT STEP"), RunState.get_final_package_next_step()))

	var footer_row := GridContainer.new()
	footer_row.columns = 1 if narrow_layout else 3
	footer_row.add_theme_constant_override("h_separation", 14)
	footer_row.add_theme_constant_override("v_separation", 12)
	footer_row.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(footer_row)
	_register_reveal(footer_row)

	var footer := Label.new()
	footer.text = _t("回车主菜单    R 重开章节    Esc 主菜单", "Enter Main Menu    R Retry Chapter    Esc Main Menu")
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if narrow_layout else HORIZONTAL_ALIGNMENT_LEFT
	footer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	_mark_read_only(footer)
	footer_row.add_child(footer)

	var retry_button := Button.new()
	retry_button.text = _t("重开章节", "Retry Chapter")
	retry_button.custom_minimum_size = Vector2(0, 52)
	retry_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	retry_button.pressed.connect(func() -> void:
		RunState.start_chapter()
	)
	footer_row.add_child(retry_button)

	var menu_button := Button.new()
	menu_button.text = _t("主菜单", "Main Menu")
	menu_button.custom_minimum_size = Vector2(0, 48)
	menu_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	_mark_read_only(panel)
	_mark_read_only(title)
	_mark_read_only(value)
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
	_mark_read_only(panel)
	_mark_read_only(title)
	_mark_read_only(body)

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
		status.text = _t("通关  评级 %s", "CLEAR  GRADE %s") % String(card_data.get("grade", "--"))
		status.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	elif bool(card_data.get("active", false)):
		status.text = _t("进行中", "ACTIVE")
		status.add_theme_color_override("font_color", Color(0.82, 0.94, 1.0))
	else:
		status.text = _t("待开始", "PENDING")
		status.add_theme_color_override("font_color", Color(0.7, 0.74, 0.8))
	status.add_theme_font_size_override("font_size", 15)
	column.add_child(status)

	var summary := Label.new()
	summary.text = String(card_data.get("summary", ""))
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 14)
	column.add_child(summary)
	_mark_read_only(panel)
	_mark_read_only(title)
	_mark_read_only(status)
	_mark_read_only(summary)

	return panel


func _build_ending_overlay() -> CanvasItem:
	var narrow_layout := get_viewport_rect().size.x <= 560.0
	var overlay_width := maxf(280.0, minf(620.0, get_viewport_rect().size.x - 64.0))
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.0)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 6)
	panel.custom_minimum_size = Vector2(overlay_width, 0.0)
	panel.modulate.a = 0.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(panel)

	var status := Label.new()
	status.text = _t("结尾 // 风暴前线已压制", "ENDING // STORM FRONT SECURED")
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 20)
	status.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	_mark_read_only(status)
	panel.add_child(status)

	var title := Label.new()
	title.text = _t("章节路线已锁定", "CHAPTER ROUTE LOCKED")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 32 if narrow_layout else 38)
	_mark_read_only(title)
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.text = RunState.get_chapter_outro_headline()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.custom_minimum_size = Vector2(overlay_width, 0.0)
	subtitle.add_theme_font_size_override("font_size", 18 if narrow_layout else 20)
	_mark_read_only(subtitle)
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
	tween.finished.connect(func() -> void:
		if is_instance_valid(ending_overlay):
			ending_overlay.queue_free()
			ending_overlay = null
	)


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


func _t(zh_text: String, en_text: String) -> String:
	return RunState.loc(zh_text, en_text)


func _handle_wheel_scroll(event: InputEvent) -> bool:
	if scroll_container == null or not is_instance_valid(scroll_container):
		return false
	if event is not InputEventMouseButton:
		return false
	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed:
		return false
	if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
		scroll_container.scroll_vertical = maxi(0, scroll_container.scroll_vertical - 96)
		return true
	if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		scroll_container.scroll_vertical += 96
		return true
	return false


func _mark_read_only(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if control is Label:
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
