extends Control

const StageCatalog := preload("res://scripts/game/stage_catalog.gd")
const UiButtonStyle := preload("res://scripts/ui/ui_button_style.gd")
const MenuBackdropScript := preload("res://scripts/ui/menu_backdrop.gd")


func _ready() -> void:
	_build_ui()
	if RunState.is_autoplay():
		call_deferred("_auto_start")


func _build_ui() -> void:
	var viewport_size := get_viewport_rect().size
	var narrow_layout := viewport_size.x <= 560.0

	var background = MenuBackdropScript.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var stripe := ColorRect.new()
	stripe.color = Color(0.08, 0.16, 0.28, 0.42)
	stripe.set_anchors_preset(Control.PRESET_TOP_WIDE)
	stripe.offset_top = 90.0
	stripe.offset_bottom = 290.0
	add_child(stripe)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 12.0
	scroll.offset_top = 18.0
	scroll.offset_right = -12.0
	scroll.offset_bottom = -12.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var frame := MarginContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_constant_override("margin_left", 10 if narrow_layout else 24)
	frame.add_theme_constant_override("margin_top", 18)
	frame.add_theme_constant_override("margin_right", 10 if narrow_layout else 24)
	frame.add_theme_constant_override("margin_bottom", 18)
	scroll.add_child(frame)

	var content_width := minf(viewport_size.x - (44.0 if narrow_layout else 96.0), 860.0)
	var content_box := CenterContainer.new()
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_child(content_box)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(maxf(0.0, content_width), 0.0)
	column.add_theme_constant_override("separation", 18)
	content_box.add_child(column)

	var title := Label.new()
	title.text = "RAIDEN PROTOTYPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 30 if narrow_layout else 42)
	column.add_child(title)

	var tag := Label.new()
	tag.text = _t("公开 Demo 准备版 // RC-0.4", "PUBLIC DEMO PREP // RC-0.4")
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag.add_theme_font_size_override("font_size", 19 if narrow_layout else 24)
	column.add_child(tag)

	var summary := Label.new()
	summary.text = _t(
		"直接点击黄色按钮开始完整双关 Demo。\n一局会经历成长、炸弹救场、风暴机关、Boss 高潮和结算总结。",
		"Press the yellow button for the full two-stage demo.\nOne run covers growth, bomb saves, storm hazards, boss climax and debrief."
	)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 17 if narrow_layout else 22)
	column.add_child(summary)

	var chapter_button := Button.new()
	chapter_button.text = "%s\n%s\nStage 01 -> Stage 02\n%s" % [
		_t("开始完整 Demo", "Start Full Demo"),
		_t("推荐入口：章节连打", "Recommended Route: Chapter Run"),
		RunState.get_release_candidate_label()
	]
	chapter_button.custom_minimum_size = Vector2(0, 112 if narrow_layout else 120)
	chapter_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiButtonStyle.apply(chapter_button, Color(0.96, 0.76, 0.34), true)
	chapter_button.pressed.connect(RunState.start_chapter)
	column.add_child(chapter_button)

	var first_time_panel := PanelContainer.new()
	column.add_child(first_time_panel)

	var first_time_margin := MarginContainer.new()
	first_time_margin.add_theme_constant_override("margin_left", 14)
	first_time_margin.add_theme_constant_override("margin_top", 10)
	first_time_margin.add_theme_constant_override("margin_right", 14)
	first_time_margin.add_theme_constant_override("margin_bottom", 10)
	first_time_panel.add_child(first_time_margin)

	var first_time_label := Label.new()
	first_time_label.text = _t(
		"首次试玩提示\n- 自动射击，只需要专心移动和躲弹\n- 炸弹：Space / Shift / X，用来清屏和救场\n- 失败或通关后可按 R 重开，Esc 返回主菜单",
		"First Run Tips\n- Shooting is automatic; focus on movement and dodging\n- Bomb: Space / Shift / X for screen clears and saves\n- Press R to retry or Esc to return after a run"
	)
	first_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	first_time_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	first_time_label.add_theme_font_size_override("font_size", 15 if narrow_layout else 18)
	first_time_margin.add_child(first_time_label)

	column.add_child(_build_settings_panel(narrow_layout))

	var practice_label := Label.new()
	practice_label.text = _t("练习入口（可选）", "Practice Routes (Optional)")
	practice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	practice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	practice_label.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	practice_label.add_theme_color_override("font_color", Color(0.78, 0.88, 1.0))
	column.add_child(practice_label)

	var stage_button_row := GridContainer.new()
	stage_button_row.columns = 1 if narrow_layout else 2
	stage_button_row.add_theme_constant_override("h_separation", 12)
	stage_button_row.add_theme_constant_override("v_separation", 12)
	column.add_child(stage_button_row)

	for stage_id in ["stage_1", "stage_2"]:
		var meta := StageCatalog.get_stage_meta(stage_id)
		var button := Button.new()
		button.text = "%s\n%s" % [
			_get_stage_menu_label(stage_id, meta),
			_get_stage_tagline(stage_id, meta)
		]
		button.custom_minimum_size = Vector2(0, 72)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiButtonStyle.apply(button, Color(0.58, 0.88, 1.0), false)
		button.pressed.connect(RunState.start_game.bind(stage_id))
		stage_button_row.add_child(button)

	var features := Label.new()
	features.text = _t(
		"版本状态：\n- Chapter Run 是当前推荐试玩路线\n- Stage 01 负责成长和炸弹节奏\n- Stage 02 负责风暴机关、Boss 压迫和章节收束",
		"Build Status:\n- Chapter Run is the recommended demo route\n- Stage 01 builds growth and bomb routing\n- Stage 02 delivers storm hazards, boss pressure and chapter closure"
	)
	features.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	features.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	features.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	column.add_child(features)

	var assessment := Label.new()
	assessment.text = _t(
		"Demo 准备判断：\n- 当前版本已经适合小范围外部试玩\n- 后续优先观察新玩家是否看得懂、打得爽、愿意重开",
		"Demo Prep Assessment:\n- This build is ready for small external playtests\n- Next priority is whether new players understand it, enjoy it and retry"
	)
	assessment.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	assessment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	assessment.add_theme_font_size_override("font_size", 15 if narrow_layout else 17)
	column.add_child(assessment)

	var demo_panel := PanelContainer.new()
	column.add_child(demo_panel)

	var demo_margin := MarginContainer.new()
	demo_margin.add_theme_constant_override("margin_left", 12)
	demo_margin.add_theme_constant_override("margin_top", 10)
	demo_margin.add_theme_constant_override("margin_right", 12)
	demo_margin.add_theme_constant_override("margin_bottom", 10)
	demo_panel.add_child(demo_margin)

	var demo_label := Label.new()
	demo_label.text = "%s\n\n%s" % [
		RunState.get_demo_route_summary(),
		RunState.get_demo_checklist_text()
	]
	demo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	demo_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	demo_label.add_theme_font_size_override("font_size", 15 if narrow_layout else 17)
	demo_margin.add_child(demo_label)

	if RunState.current_run.duration_sec > 0.0:
		var last_sortie := Label.new()
		last_sortie.text = "%s\n%s %s   %s %06d\n%s %.0f%%   %s Lv%d" % [
			_t("上一局：", "Last Sortie:"),
			_t("评级", "Grade"),
			RunState.get_performance_grade(),
			_t("得分", "Final"),
			RunState.current_run.final_score,
			_t("击破", "Kill"),
			RunState.get_kill_rate(),
			_t("火力上限", "Max Fire"),
			RunState.current_run.max_fire_level
		]
		last_sortie.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		last_sortie.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		last_sortie.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
		column.add_child(last_sortie)

	var hint := Label.new()
	hint.text = _t(
		"移动：WASD / 方向键    炸弹：Space / Shift / X    暂停：Esc / P    重开：R",
		"Move: WASD / Arrows    Bomb: Space / Shift / X    Pause: Esc / P    Retry: R"
	)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	column.add_child(hint)


func _build_settings_panel(narrow_layout: bool) -> Control:
	var panel := PanelContainer.new()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var settings_row := HBoxContainer.new()
	settings_row.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_row.add_theme_constant_override("separation", 10)
	column.add_child(settings_row)

	var language_label := Label.new()
	language_label.text = _t("语言", "Language")
	language_label.add_theme_font_size_override("font_size", 18)
	settings_row.add_child(language_label)

	var chinese_button := Button.new()
	chinese_button.text = "中文"
	chinese_button.custom_minimum_size = Vector2(88, 40)
	chinese_button.disabled = RunState.get_language_code() == "zh_CN"
	UiButtonStyle.apply(chinese_button, Color(0.58, 0.78, 1.0), false)
	chinese_button.pressed.connect(func() -> void:
		RunState.set_language_code("zh_CN")
		get_tree().reload_current_scene()
	)
	settings_row.add_child(chinese_button)

	var english_button := Button.new()
	english_button.text = "English"
	english_button.custom_minimum_size = Vector2(110, 40)
	english_button.disabled = RunState.get_language_code() == "en"
	UiButtonStyle.apply(english_button, Color(0.58, 0.78, 1.0), false)
	english_button.pressed.connect(func() -> void:
		RunState.set_language_code("en")
		get_tree().reload_current_scene()
	)
	settings_row.add_child(english_button)

	var audio_title := Label.new()
	audio_title.text = _t("音频设置", "Audio Mix")
	audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_title.add_theme_font_size_override("font_size", 16 if narrow_layout else 18)
	audio_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	column.add_child(audio_title)

	column.add_child(_build_audio_slider_row(
		_t("音乐", "BGM"),
		RunState.get_bgm_volume(),
		func(value: float) -> void:
			RunState.set_bgm_volume(value, false),
		func(value: float) -> void:
			RunState.set_bgm_volume(value, true)
	))
	column.add_child(_build_audio_slider_row(
		_t("音效", "SFX"),
		RunState.get_sfx_volume(),
		func(value: float) -> void:
			RunState.set_sfx_volume(value, false),
		func(value: float) -> void:
			RunState.set_sfx_volume(value, true)
	))

	return panel


func _build_audio_slider_row(title_text: String, initial_value: float, on_change: Callable, on_commit: Callable) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	row.add_child(header)

	var title := Label.new()
	title.text = title_text
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 15)
	header.add_child(title)

	var value_label := Label.new()
	value_label.text = _format_percentage(initial_value)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size = Vector2(56.0, 0.0)
	value_label.add_theme_font_size_override("font_size", 15)
	header.add_child(value_label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.2
	slider.step = 0.01
	slider.value = initial_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(func(value: float) -> void:
		value_label.text = _format_percentage(value)
		on_change.call(value)
	)
	slider.drag_ended.connect(func(value_changed: bool) -> void:
		if value_changed:
			on_commit.call(slider.value)
	)
	row.add_child(slider)
	return row


func _format_percentage(value: float) -> String:
	return "%d%%" % int(round(value * 100.0))


func _auto_start() -> void:
	if RunState.wants_autoplay_chapter():
		RunState.start_chapter()
	else:
		RunState.start_game(RunState.get_requested_autoplay_stage())


func _t(zh_text: String, en_text: String) -> String:
	return en_text if RunState.is_english() else zh_text


func _get_stage_menu_label(stage_id: String, meta: Dictionary) -> String:
	if RunState.is_english():
		return String(meta.get("menu_label", stage_id))
	match stage_id:
		"stage_1":
			return "第一关"
		"stage_2":
			return "第二关"
		_:
			return String(meta.get("menu_label_zh", meta.get("menu_label", stage_id)))


func _get_stage_tagline(stage_id: String, meta: Dictionary) -> String:
	if RunState.is_english():
		return String(meta.get("tagline", ""))
	match stage_id:
		"stage_1":
			return "建立成长与开场节奏"
		"stage_2":
			return "风暴机关与 Boss 高潮"
		_:
			return String(meta.get("tagline_zh", meta.get("tagline", "")))
