extends Control

const BgmControllerScript := preload("res://scripts/game/bgm_controller.gd")

var reveal_nodes: Array[CanvasItem] = []
var top_bar: ColorRect
var bottom_bar: ColorRect
var pulse_glow: ColorRect
var seal_panel: PanelContainer
var seal_label: Label
var route_band: PanelContainer
var route_band_fill: ColorRect
var route_band_text: Label
var bgm


func _ready() -> void:
	_build_ui()
	_play_intro_motion()
	_play_reveal_sequence()
	_play_audio()
	if RunState.is_autoplay():
		get_tree().create_timer(1.05).timeout.connect(func() -> void:
			RunState.show_chapter_outro()
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		RunState.show_chapter_outro()
	elif event.is_action_pressed("restart_game") and not event.is_echo():
		RunState.start_chapter()
	elif event.is_action_pressed("ui_cancel") and not event.is_echo():
		RunState.go_to_menu()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.015, 0.02, 0.05)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	pulse_glow = ColorRect.new()
	pulse_glow.color = Color(0.96, 0.78, 0.36, 0.06)
	pulse_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(pulse_glow)

	for index in range(7):
		var stripe := ColorRect.new()
		stripe.color = Color(0.96, 0.82, 0.48, 0.05 if index % 2 == 0 else 0.025)
		stripe.anchor_left = 0.0
		stripe.anchor_right = 1.0
		stripe.offset_top = 108.0 + float(index) * 88.0
		stripe.offset_bottom = stripe.offset_top + 2.0
		add_child(stripe)

	top_bar = ColorRect.new()
	top_bar.color = Color(0.0, 0.0, 0.0, 0.92)
	top_bar.anchor_right = 1.0
	add_child(top_bar)

	bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.0, 0.0, 0.0, 0.92)
	bottom_bar.anchor_top = 1.0
	bottom_bar.anchor_right = 1.0
	bottom_bar.anchor_bottom = 1.0
	add_child(bottom_bar)

	var frame := MarginContainer.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 72)
	frame.add_theme_constant_override("margin_top", 110)
	frame.add_theme_constant_override("margin_right", 72)
	frame.add_theme_constant_override("margin_bottom", 110)
	add_child(frame)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	frame.add_child(root)

	var accent_color := _get_grade_color()

	seal_panel = PanelContainer.new()
	seal_panel.set_anchors_preset(Control.PRESET_CENTER)
	seal_panel.offset_left = -150.0
	seal_panel.offset_top = -74.0
	seal_panel.offset_right = 150.0
	seal_panel.offset_bottom = 74.0
	seal_panel.modulate.a = 0.0
	add_child(seal_panel)

	var seal_margin := MarginContainer.new()
	seal_margin.add_theme_constant_override("margin_left", 16)
	seal_margin.add_theme_constant_override("margin_top", 12)
	seal_margin.add_theme_constant_override("margin_right", 16)
	seal_margin.add_theme_constant_override("margin_bottom", 12)
	seal_panel.add_child(seal_margin)

	var seal_column := VBoxContainer.new()
	seal_column.add_theme_constant_override("separation", 4)
	seal_margin.add_child(seal_column)

	var seal_title := Label.new()
	seal_title.text = "ROUTE SEAL"
	seal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal_title.add_theme_font_size_override("font_size", 18)
	seal_title.add_theme_color_override("font_color", accent_color)
	seal_column.add_child(seal_title)

	seal_label = Label.new()
	seal_label.text = "CHAPTER %s" % RunState.get_chapter_grade()
	seal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal_label.add_theme_font_size_override("font_size", 34)
	seal_label.add_theme_color_override("font_color", accent_color)
	seal_column.add_child(seal_label)

	var seal_summary := Label.new()
	seal_summary.text = "Storm Front secured"
	seal_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal_summary.add_theme_font_size_override("font_size", 18)
	seal_column.add_child(seal_summary)

	var hero := VBoxContainer.new()
	hero.add_theme_constant_override("separation", 6)
	root.add_child(hero)
	_register_reveal(hero)

	var banner := Label.new()
	banner.text = RunState.get_chapter_ending_banner()
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 18)
	banner.add_theme_color_override("font_color", accent_color)
	hero.add_child(banner)

	var title := Label.new()
	title.text = RunState.get_chapter_ending_title()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	hero.add_child(title)

	var subtitle := Label.new()
	subtitle.text = RunState.get_chapter_ending_summary()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 20)
	hero.add_child(subtitle)

	route_band = PanelContainer.new()
	root.add_child(route_band)
	_register_reveal(route_band)

	var route_margin := MarginContainer.new()
	route_margin.add_theme_constant_override("margin_left", 12)
	route_margin.add_theme_constant_override("margin_top", 10)
	route_margin.add_theme_constant_override("margin_right", 12)
	route_margin.add_theme_constant_override("margin_bottom", 10)
	route_band.add_child(route_margin)

	var route_overlay := Control.new()
	route_overlay.custom_minimum_size = Vector2(0, 60)
	route_overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_margin.add_child(route_overlay)

	route_band_fill = ColorRect.new()
	route_band_fill.color = Color(accent_color.r, accent_color.g, accent_color.b, 0.22)
	route_band_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	route_band_fill.offset_top = 18.0
	route_band_fill.offset_bottom = -18.0
	route_band_fill.scale = Vector2(0.0, 1.0)
	route_band_fill.pivot_offset = Vector2(0.0, 12.0)
	route_overlay.add_child(route_band_fill)

	route_band_text = Label.new()
	route_band_text.text = "SCRAMBLE SECURED  ->  STORM FRONT COLLAPSED  ->  ROUTE LOCKED"
	route_band_text.set_anchors_preset(Control.PRESET_FULL_RECT)
	route_band_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	route_band_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	route_band_text.add_theme_font_size_override("font_size", 20)
	route_overlay.add_child(route_band_text)

	var score_row := HBoxContainer.new()
	score_row.add_theme_constant_override("separation", 14)
	root.add_child(score_row)
	_register_reveal(score_row)
	score_row.add_child(_build_stat_card("CHAPTER GRADE", RunState.get_chapter_grade()))
	score_row.add_child(_build_stat_card("TOTAL SCORE", "%06d" % int(RunState.chapter_state.get("total_score", 0))))
	score_row.add_child(_build_stat_card("CHAPTER KILL", "%.0f%%" % RunState.get_chapter_kill_rate()))

	var timeline_row := HBoxContainer.new()
	timeline_row.add_theme_constant_override("separation", 12)
	root.add_child(timeline_row)
	_register_reveal(timeline_row)
	for card_data in RunState.get_chapter_timeline():
		timeline_row.add_child(_build_stage_card(card_data))

	var verdict_panel := PanelContainer.new()
	root.add_child(verdict_panel)
	_register_reveal(verdict_panel)

	var verdict_margin := MarginContainer.new()
	verdict_margin.add_theme_constant_override("margin_left", 12)
	verdict_margin.add_theme_constant_override("margin_top", 10)
	verdict_margin.add_theme_constant_override("margin_right", 12)
	verdict_margin.add_theme_constant_override("margin_bottom", 10)
	verdict_panel.add_child(verdict_margin)

	var verdict_column := VBoxContainer.new()
	verdict_column.add_theme_constant_override("separation", 6)
	verdict_margin.add_child(verdict_column)

	var verdict_title := Label.new()
	verdict_title.text = "SLICE VERDICT"
	verdict_title.add_theme_font_size_override("font_size", 16)
	verdict_title.add_theme_color_override("font_color", accent_color)
	verdict_column.add_child(verdict_title)

	var verdict_body := Label.new()
	verdict_body.text = RunState.get_chapter_ending_verdict()
	verdict_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	verdict_body.add_theme_font_size_override("font_size", 18)
	verdict_column.add_child(verdict_body)

	var footer_row := HBoxContainer.new()
	footer_row.alignment = BoxContainer.ALIGNMENT_CENTER
	footer_row.add_theme_constant_override("separation", 14)
	root.add_child(footer_row)
	_register_reveal(footer_row)

	var footer := Label.new()
	footer.text = "Enter Debrief    R Retry Chapter    Esc Main Menu"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	footer_row.add_child(footer)

	var debrief_button := Button.new()
	debrief_button.text = "Debrief"
	debrief_button.custom_minimum_size = Vector2(180, 52)
	debrief_button.pressed.connect(func() -> void:
		RunState.show_chapter_outro()
	)
	footer_row.add_child(debrief_button)

	var retry_button := Button.new()
	retry_button.text = "Retry Chapter"
	retry_button.custom_minimum_size = Vector2(190, 52)
	retry_button.pressed.connect(func() -> void:
		RunState.start_chapter()
	)
	footer_row.add_child(retry_button)


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
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	column.add_child(title)

	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 24)
	column.add_child(value)

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
	status.text = "CLEAR  GRADE %s" % String(card_data.get("grade", "--"))
	status.add_theme_font_size_override("font_size", 15)
	status.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
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
		top_bar.offset_bottom = 58.0
		bottom_bar.offset_top = -58.0
		pulse_glow.color.a = 0.14
		seal_panel.modulate.a = 1.0
		route_band_fill.scale.x = 1.0
		return

	var bar_tween := create_tween()
	bar_tween.tween_property(top_bar, "offset_bottom", 58.0, 0.28)
	bar_tween.parallel().tween_property(bottom_bar, "offset_top", -58.0, 0.28)

	var pulse_tween := create_tween().set_loops()
	pulse_tween.tween_property(pulse_glow, "color:a", 0.16, 0.42)
	pulse_tween.tween_property(pulse_glow, "color:a", 0.05, 0.55)

	var seal_tween := create_tween()
	seal_tween.tween_property(seal_panel, "modulate:a", 1.0, 0.2)
	seal_tween.tween_interval(0.34)
	seal_tween.tween_property(seal_panel, "modulate:a", 0.0, 0.22)

	var route_tween := create_tween()
	route_tween.tween_interval(0.58)
	route_tween.tween_property(route_band_fill, "scale:x", 1.0, 0.48)


func _play_reveal_sequence() -> void:
	if RunState.is_autoplay():
		for item in reveal_nodes:
			item.modulate.a = 1.0
		return

	for index in range(reveal_nodes.size()):
		var target := reveal_nodes[index]
		var delay := 0.12 * float(index)
		get_tree().create_timer(0.56 + delay).timeout.connect(func() -> void:
			if not is_instance_valid(target):
				return
			var tween := create_tween()
			tween.tween_property(target, "modulate:a", 1.0, 0.24)
		)


func _play_audio() -> void:
	if DisplayServer.get_name() == "headless":
		return
	bgm = BgmControllerScript.new()
	add_child(bgm)
	bgm.play_chapter_end_sting()


func _get_grade_color() -> Color:
	match RunState.get_chapter_grade():
		"S":
			return Color(1.0, 0.9, 0.58)
		"A":
			return Color(0.82, 0.94, 1.0)
		"B":
			return Color(0.92, 0.84, 0.56)
		_:
			return Color(0.84, 0.84, 0.9)
