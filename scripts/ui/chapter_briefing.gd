extends Control

var reveal_nodes: Array[CanvasItem] = []
var top_bar: ColorRect
var bottom_bar: ColorRect
var scan_line: ColorRect


func _ready() -> void:
	_build_ui()
	_play_intro_motion()
	_play_reveal_sequence()
	if RunState.is_autoplay():
		get_tree().create_timer(0.7).timeout.connect(func() -> void:
			RunState.start_next_chapter_stage()
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		RunState.start_next_chapter_stage()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		RunState.go_to_menu()


func _build_ui() -> void:
	var next_meta := RunState.get_next_stage_meta()

	var background := ColorRect.new()
	background.color = Color(0.015, 0.025, 0.05)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var storm_glow := ColorRect.new()
	storm_glow.color = Color(0.18, 0.34, 0.54, 0.16)
	storm_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(storm_glow)

	for index in range(8):
		var stripe := ColorRect.new()
		stripe.color = Color(0.18, 0.52, 0.88, 0.05 if index % 2 == 0 else 0.025)
		stripe.anchor_left = 0.0
		stripe.anchor_right = 1.0
		stripe.anchor_top = 0.0
		stripe.anchor_bottom = 0.0
		stripe.offset_top = 72.0 + 68.0 * float(index)
		stripe.offset_bottom = stripe.offset_top + 2.0
		add_child(stripe)

	top_bar = ColorRect.new()
	top_bar.color = Color(0.0, 0.0, 0.0, 0.88)
	top_bar.anchor_right = 1.0
	top_bar.offset_bottom = 0.0
	add_child(top_bar)

	bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.0, 0.0, 0.0, 0.88)
	bottom_bar.anchor_top = 1.0
	bottom_bar.anchor_right = 1.0
	bottom_bar.anchor_bottom = 1.0
	bottom_bar.offset_top = 0.0
	add_child(bottom_bar)

	scan_line = ColorRect.new()
	scan_line.color = Color(0.72, 0.94, 1.0, 0.12)
	scan_line.anchor_right = 1.0
	scan_line.offset_top = 180.0
	scan_line.offset_bottom = 186.0
	add_child(scan_line)

	var frame := MarginContainer.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 56)
	frame.add_theme_constant_override("margin_top", 78)
	frame.add_theme_constant_override("margin_right", 56)
	frame.add_theme_constant_override("margin_bottom", 78)
	add_child(frame)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	frame.add_child(root)
	var narrow_layout := get_viewport_rect().size.x <= 560.0

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	root.add_child(header)
	_register_reveal(header)

	var status := Label.new()
	status.text = _t("过场已锁定 // 第二段待命", "TRANSITION LOCKED // LEG 2 READY")
	status.add_theme_font_size_override("font_size", 18)
	status.add_theme_color_override("font_color", Color(0.82, 0.94, 1.0))
	header.add_child(status)

	var title := Label.new()
	title.text = RunState.get_stage_display_name(String(next_meta.get("id", "")))
	title.add_theme_font_size_override("font_size", 40)
	header.add_child(title)

	var tagline := Label.new()
	tagline.text = RunState.get_stage_display_tagline(String(next_meta.get("id", ""))) if not next_meta.is_empty() else _t("准备进入下一战区。", "Proceed to the next combat zone.")
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tagline.add_theme_font_size_override("font_size", 20)
	header.add_child(tagline)

	var timeline_row := GridContainer.new()
	timeline_row.columns = 1 if narrow_layout else 2
	timeline_row.add_theme_constant_override("h_separation", 12)
	timeline_row.add_theme_constant_override("v_separation", 12)
	root.add_child(timeline_row)
	_register_reveal(timeline_row)
	for card_data in RunState.get_chapter_timeline():
		timeline_row.add_child(_build_stage_card(card_data))

	var focus_row := GridContainer.new()
	focus_row.columns = 1 if narrow_layout else 2
	focus_row.add_theme_constant_override("h_separation", 16)
	focus_row.add_theme_constant_override("v_separation", 16)
	root.add_child(focus_row)
	_register_reveal(focus_row)

	focus_row.add_child(_build_panel(
		_t("任务简报", "MISSION FEED"),
		"%s\n\n%s" % [
			RunState.get_chapter_transition_text(),
			RunState.get_chapter_transition_brief()
		]
	))
	focus_row.add_child(_build_panel(
		_t("继承装载", "CARRY LOADOUT"),
		"%s\n\n%s" % [
			RunState.get_chapter_carry_summary(),
			_t("第一关已经通过，当前路线会把炸弹节奏和高火力连续性一起带进风暴段。", "Stage 01 cleared. Current route is carrying bomb tempo and high-fire continuity into the storm lane.")
		]
	))

	var timeline_panel := _build_panel(
		_t("路线时间线", "ROUTE TIMELINE"),
		"%s\n\n%s\n%s" % [
			RunState.get_chapter_stage_breakdown_text(),
			_t("出击指令", "DEPLOY DIRECTIVE"),
			_t("按回车立即出击，按 Esc 返回主菜单。", "Enter to launch immediately. Esc returns to main menu.")
		]
	)
	root.add_child(timeline_panel)
	_register_reveal(timeline_panel)

	var footer_row := HBoxContainer.new()
	footer_row.alignment = BoxContainer.ALIGNMENT_END
	footer_row.add_theme_constant_override("separation", 14)
	root.add_child(footer_row)
	_register_reveal(footer_row)

	var footer := Label.new()
	footer.text = _t("回车出击    Esc 主菜单", "Enter Deploy    Esc Main Menu")
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	footer_row.add_child(footer)

	var deploy_button := Button.new()
	deploy_button.text = _t("出击", "Deploy")
	deploy_button.custom_minimum_size = Vector2(190, 54)
	deploy_button.pressed.connect(func() -> void:
		RunState.start_next_chapter_stage()
	)
	footer_row.add_child(deploy_button)

	var menu_button := Button.new()
	menu_button.text = _t("主菜单", "Main Menu")
	menu_button.custom_minimum_size = Vector2(170, 48)
	menu_button.pressed.connect(func() -> void:
		RunState.go_to_menu()
	)
	footer_row.add_child(menu_button)


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
	title.add_theme_color_override("font_color", Color(0.84, 0.94, 1.0))
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
		status.text = _t("已完成", "SECURED")
		status.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	elif bool(card_data.get("active", false)):
		status.text = _t("出击中", "DEPLOYING")
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

	return panel


func _register_reveal(item: CanvasItem) -> void:
	item.modulate.a = 0.0
	reveal_nodes.append(item)


func _play_intro_motion() -> void:
	if RunState.is_autoplay():
		top_bar.offset_bottom = 48.0
		bottom_bar.offset_top = -48.0
		return

	var bar_tween := create_tween()
	bar_tween.tween_property(top_bar, "offset_bottom", 48.0, 0.28)
	bar_tween.parallel().tween_property(bottom_bar, "offset_top", -48.0, 0.28)

	var scan_tween := create_tween().set_loops()
	scan_tween.tween_property(scan_line, "position:y", 420.0, 1.2)
	scan_tween.tween_property(scan_line, "position:y", 180.0, 0.0)


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
