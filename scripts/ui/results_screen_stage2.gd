extends Control

const UiButtonStyle := preload("res://scripts/ui/ui_button_style.gd")

var reveal_nodes: Array[CanvasItem] = []
var scroll_container: ScrollContainer


func _ready() -> void:
	_build_ui()
	_play_reveal_sequence()
	if RunState.is_autoplay():
		get_tree().create_timer(0.4).timeout.connect(func() -> void:
			if RunState.is_chapter_transition_pending():
				RunState.show_chapter_briefing()
			elif RunState.is_chapter_complete():
				RunState.show_chapter_ending()
			else:
				get_tree().quit()
		)


func _input(event: InputEvent) -> void:
	if _handle_wheel_scroll(event):
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo() and RunState.is_chapter_transition_pending():
		RunState.show_chapter_briefing()
	elif event.is_action_pressed("ui_accept") and not event.is_echo() and RunState.is_chapter_complete():
		RunState.show_chapter_ending()
	elif event.is_action_pressed("restart_game") and not event.is_echo():
		if RunState.is_chapter_complete():
			RunState.start_chapter()
		else:
			RunState.retry_run()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		RunState.go_to_menu()


func _build_ui() -> void:
	var viewport_size := get_viewport_rect().size
	var narrow_layout := viewport_size.x <= 560.0

	var background := ColorRect.new()
	background.color = Color(0.03, 0.04, 0.08)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var glow_top := ColorRect.new()
	glow_top.color = Color(0.22, 0.32, 0.52, 0.22)
	glow_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	glow_top.offset_bottom = 180.0
	glow_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow_top)

	var glow_bottom := ColorRect.new()
	glow_bottom.color = Color(0.72, 0.34, 0.22, 0.12) if RunState.current_run.victory else Color(0.62, 0.18, 0.18, 0.14)
	glow_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	glow_bottom.offset_top = -220.0
	glow_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow_bottom)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 14.0
	panel.offset_top = 14.0
	panel.offset_right = -14.0
	panel.offset_bottom = -14.0
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14 if narrow_layout else 20)
	margin.add_theme_constant_override("margin_top", 14 if narrow_layout else 20)
	margin.add_theme_constant_override("margin_right", 14 if narrow_layout else 20)
	margin.add_theme_constant_override("margin_bottom", 14 if narrow_layout else 20)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 12)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(root)

	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll_container)

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.custom_minimum_size = Vector2(maxf(0.0, viewport_size.x - 68.0), 0.0)
	column.add_theme_constant_override("separation", 14)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll_container.add_child(column)

	var hero_box := VBoxContainer.new()
	hero_box.add_theme_constant_override("separation", 6)
	column.add_child(hero_box)
	_register_reveal(hero_box)

	var title := Label.new()
	title.text = RunState.get_result_title()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 28 if narrow_layout else 36)
	_mark_read_only(title)
	hero_box.add_child(title)

	var grade := Label.new()
	grade.text = "%s %s" % [_t("评级", "GRADE"), (RunState.get_chapter_grade() if RunState.is_chapter_complete() else RunState.get_performance_grade())]
	grade.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade.add_theme_font_size_override("font_size", 24 if narrow_layout else 30)
	grade.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5) if RunState.current_run.victory else Color(1.0, 0.6, 0.48))
	_mark_read_only(grade)
	hero_box.add_child(grade)

	var flavor := Label.new()
	flavor.text = RunState.get_result_flavor()
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	_mark_read_only(flavor)
	hero_box.add_child(flavor)

	var tags := Label.new()
	tags.text = " / ".join(RunState.get_result_tags())
	tags.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tags.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tags.add_theme_font_size_override("font_size", 14 if narrow_layout else 16)
	_mark_read_only(tags)
	hero_box.add_child(tags)

	if RunState.is_chapter_mode():
		var timeline_row := GridContainer.new()
		timeline_row.columns = 1 if narrow_layout else 2
		timeline_row.add_theme_constant_override("h_separation", 10)
		timeline_row.add_theme_constant_override("v_separation", 10)
		column.add_child(timeline_row)
		_register_reveal(timeline_row)
		for card_data in RunState.get_chapter_timeline():
			timeline_row.add_child(_build_chapter_stage_card(card_data))

	if RunState.is_chapter_mode():
		var chapter_panel := PanelContainer.new()
		column.add_child(chapter_panel)
		_register_reveal(chapter_panel)
		var chapter_margin := MarginContainer.new()
		chapter_margin.add_theme_constant_override("margin_left", 12)
		chapter_margin.add_theme_constant_override("margin_top", 10)
		chapter_margin.add_theme_constant_override("margin_right", 12)
		chapter_margin.add_theme_constant_override("margin_bottom", 10)
		chapter_panel.add_child(chapter_margin)
		var chapter_label := Label.new()
		chapter_label.text = "%s\n%s" % [RunState.get_chapter_progress_text(), RunState.get_chapter_stage_breakdown_text()]
		chapter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chapter_label.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
		_mark_read_only(chapter_panel)
		_mark_read_only(chapter_label)
		chapter_margin.add_child(chapter_label)

	if RunState.is_chapter_complete():
		var chapter_clear_panel := PanelContainer.new()
		column.add_child(chapter_clear_panel)
		_register_reveal(chapter_clear_panel)
		var chapter_clear_margin := MarginContainer.new()
		chapter_clear_margin.add_theme_constant_override("margin_left", 12)
		chapter_clear_margin.add_theme_constant_override("margin_top", 10)
		chapter_clear_margin.add_theme_constant_override("margin_right", 12)
		chapter_clear_margin.add_theme_constant_override("margin_bottom", 10)
		chapter_clear_panel.add_child(chapter_clear_margin)
		var chapter_clear_column := VBoxContainer.new()
		chapter_clear_column.add_theme_constant_override("separation", 10)
		chapter_clear_margin.add_child(chapter_clear_column)
		var chapter_clear_label := Label.new()
		chapter_clear_label.text = "%s\n%s" % [_t("章节总结", "CHAPTER SUMMARY"), RunState.get_chapter_clear_summary()]
		chapter_clear_label.add_theme_font_size_override("font_size", 18 if narrow_layout else 20)
		chapter_clear_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chapter_clear_column.add_child(chapter_clear_label)

		var epilogue_label := Label.new()
		epilogue_label.text = "%s\n%s" % [_t("尾声", "EPILOGUE"), RunState.get_chapter_epilogue()]
		epilogue_label.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
		epilogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chapter_clear_column.add_child(epilogue_label)
		_mark_read_only(chapter_clear_panel)
		_mark_read_only(chapter_clear_label)
		_mark_read_only(epilogue_label)

	if RunState.is_chapter_transition_pending():
		var transition_panel := PanelContainer.new()
		column.add_child(transition_panel)
		_register_reveal(transition_panel)
		var transition_margin := MarginContainer.new()
		transition_margin.add_theme_constant_override("margin_left", 12)
		transition_margin.add_theme_constant_override("margin_top", 10)
		transition_margin.add_theme_constant_override("margin_right", 12)
		transition_margin.add_theme_constant_override("margin_bottom", 10)
		transition_panel.add_child(transition_margin)
		var transition_label := Label.new()
		transition_label.text = "%s\n%s\n%s\n%s" % [
			_t("章节推进", "CHAPTER ADVANCE"),
			RunState.get_chapter_transition_text(),
			RunState.get_chapter_carry_summary(),
			RunState.get_chapter_transition_brief()
		]
		transition_label.add_theme_font_size_override("font_size", 18 if narrow_layout else 20)
		transition_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_mark_read_only(transition_panel)
		_mark_read_only(transition_label)
		transition_margin.add_child(transition_label)

	var stat_row := GridContainer.new()
	stat_row.columns = 1 if narrow_layout else 3
	stat_row.add_theme_constant_override("h_separation", 10)
	stat_row.add_theme_constant_override("v_separation", 10)
	column.add_child(stat_row)
	_register_reveal(stat_row)
	if RunState.is_chapter_complete():
		stat_row.add_child(_build_stat_card(_t("章节得分", "CHAPTER SCORE"), "%06d" % int(RunState.chapter_state.get("total_score", 0))))
		stat_row.add_child(_build_stat_card(_t("章节击破", "CHAPTER KILL"), "%.0f%%" % RunState.get_chapter_kill_rate()))
		stat_row.add_child(_build_stat_card(_t("最高火力", "HIGH FIRE"), "Lv%d" % int(RunState.chapter_state.get("highest_fire", 1))))
	else:
		stat_row.add_child(_build_stat_card(_t("最终得分", "FINAL SCORE"), "%06d" % int(RunState.current_run.final_score)))
		stat_row.add_child(_build_stat_card(_t("击破率", "KILL RATE"), "%.0f%%" % RunState.get_kill_rate()))
		stat_row.add_child(_build_stat_card(_t("最高火力", "MAX FIRE"), "Lv%d" % int(RunState.current_run.max_fire_level)))

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
	route_label.text = "%s\n%s  %s" % [RunState.get_stage_display_name(String(RunState.current_run.get("stage_id", RunState.get_selected_stage_id()))), _t("火力路线", "FIRE ROUTE"), RunState.get_fire_route_text()]
	route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_label.add_theme_font_size_override("font_size", 17 if narrow_layout else 20)
	_mark_read_only(route_panel)
	_mark_read_only(route_label)
	route_margin.add_child(route_label)

	var insight_row := GridContainer.new()
	insight_row.columns = 1 if narrow_layout else 3
	insight_row.add_theme_constant_override("h_separation", 10)
	insight_row.add_theme_constant_override("v_separation", 10)
	column.add_child(insight_row)
	_register_reveal(insight_row)
	insight_row.add_child(_build_text_card(_t("输出", "OFFENSE"), RunState.get_offense_summary()))
	insight_row.add_child(_build_text_card(_t("生存", "SURVIVAL"), RunState.get_survival_summary()))
	insight_row.add_child(_build_text_card(_t("资源", "RESOURCE"), RunState.get_resource_summary()))

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
	score_breakdown.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	score_breakdown.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mark_read_only(score_breakdown)
	breakdown_column.add_child(score_breakdown)

	var detail := Label.new()
	detail.text = _t(
		"起始生命：%d    起始炸弹：%d    起始火力：Lv%d\n使用炸弹：%d    拾取炸弹：%d\n火力补给：%d    损失生命：%d\nBoss 击破：%s    用时：%.1f 秒",
		"Start Hull: %d    Start Bomb: %d    Start Fire: Lv%d\nBombs Used: %d    Bombs Picked: %d\nPower Pickups: %d    Lives Lost: %d\nBoss Defeated: %s    Run Time: %.1f sec"
	) % [
		RunState.current_run.start_lives,
		RunState.current_run.start_bombs,
		RunState.current_run.start_fire_level,
		RunState.current_run.bombs_used,
		RunState.current_run.bombs_collected,
		RunState.current_run.upgrades_collected,
		RunState.get_lives_lost(),
		(_t("是", "Yes") if RunState.current_run.boss_defeated else _t("否", "No")),
		RunState.current_run.duration_sec
	]
	detail.add_theme_font_size_override("font_size", 18)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mark_read_only(breakdown_panel)
	_mark_read_only(detail)
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
	analysis.text = "%s  %s" % [_t("下一步重点", "NEXT FOCUS"), RunState.get_next_focus()]
	analysis.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	analysis.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	_mark_read_only(analysis_panel)
	_mark_read_only(analysis)
	analysis_margin.add_child(analysis)

	var footer_box := VBoxContainer.new()
	footer_box.add_theme_constant_override("separation", 10)
	footer_box.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(footer_box)
	_register_reveal(footer_box)

	var footer := Label.new()
	footer.text = (
		_t("回车进入简报    R 重开    Esc 主菜单", "Enter Briefing    R Retry    Esc Main Menu")
		if RunState.is_chapter_transition_pending()
		else (_t("回车进入结尾    R 重开章节    Esc 主菜单", "Enter Ending    R Retry Chapter    Esc Main Menu") if RunState.is_chapter_complete() else _t("R 重开    Esc 主菜单", "R Retry    Esc Main Menu"))
	)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_theme_font_size_override("font_size", 15 if narrow_layout else 18)
	_mark_read_only(footer)
	footer_box.add_child(footer)

	var button_row := GridContainer.new()
	button_row.columns = 1 if narrow_layout else 3
	button_row.add_theme_constant_override("h_separation", 12)
	button_row.add_theme_constant_override("v_separation", 12)
	button_row.mouse_filter = Control.MOUSE_FILTER_PASS
	footer_box.add_child(button_row)

	if RunState.is_chapter_transition_pending():
		var next_button := Button.new()
		next_button.text = _t("简报", "Briefing")
		next_button.custom_minimum_size = Vector2(0, 52)
		next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiButtonStyle.apply(next_button, Color(0.58, 0.88, 1.0), true)
		next_button.pressed.connect(func() -> void:
			RunState.show_chapter_briefing()
		)
		button_row.add_child(next_button)
	elif RunState.is_chapter_complete():
		var debrief_button := Button.new()
		debrief_button.text = _t("结尾", "Ending")
		debrief_button.custom_minimum_size = Vector2(0, 52)
		debrief_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiButtonStyle.apply(debrief_button, Color(0.96, 0.76, 0.34), true)
		debrief_button.pressed.connect(func() -> void:
			RunState.show_chapter_ending()
		)
		button_row.add_child(debrief_button)

	var again_button := Button.new()
	again_button.text = _t("重开章节", "Retry Chapter") if RunState.is_chapter_complete() else _t("重开", "Retry")
	again_button.custom_minimum_size = Vector2(0, 52)
	again_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiButtonStyle.apply(again_button, Color(0.92, 0.64, 0.32), false)
	again_button.pressed.connect(func() -> void:
		if RunState.is_chapter_complete():
			RunState.start_chapter()
		else:
			RunState.retry_run()
	)
	button_row.add_child(again_button)

	var menu_button := Button.new()
	menu_button.text = _t("主菜单", "Main Menu")
	menu_button.custom_minimum_size = Vector2(0, 48)
	menu_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiButtonStyle.apply(menu_button, Color(0.44, 0.6, 0.84), false)
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
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 14)
	column.add_child(title)

	var value := Label.new()
	value.text = value_text
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.add_theme_font_size_override("font_size", 24)
	column.add_child(value)
	_mark_read_only(panel)
	_mark_read_only(title)
	_mark_read_only(value)
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
	_mark_read_only(panel)
	_mark_read_only(title)
	_mark_read_only(body)
	return panel


func _build_chapter_stage_card(card_data: Dictionary) -> Control:
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

	var label := Label.new()
	label.text = String(card_data.get("label", "STAGE"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 16)
	column.add_child(label)

	var status := Label.new()
	if bool(card_data.get("completed", false)):
		status.text = _t("通关  评级 %s", "CLEAR  GRADE %s") % String(card_data.get("grade", "--"))
		status.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58) if bool(card_data.get("victory", false)) else Color(1.0, 0.58, 0.46))
	elif bool(card_data.get("active", false)):
		status.text = _t("当前段落", "CURRENT LEG")
		status.add_theme_color_override("font_color", Color(0.72, 0.94, 1.0))
	else:
		status.text = _t("待开始", "PENDING")
		status.add_theme_color_override("font_color", Color(0.72, 0.72, 0.78))
	status.add_theme_font_size_override("font_size", 15)
	column.add_child(status)

	var summary := Label.new()
	summary.text = String(card_data.get("summary", ""))
	summary.add_theme_font_size_override("font_size", 14)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(summary)
	_mark_read_only(panel)
	_mark_read_only(label)
	_mark_read_only(status)
	_mark_read_only(summary)
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
