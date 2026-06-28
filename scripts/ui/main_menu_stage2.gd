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
	scroll.offset_left = 10.0
	scroll.offset_top = 14.0
	scroll.offset_right = -10.0
	scroll.offset_bottom = -10.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var frame := MarginContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_constant_override("margin_left", 8 if narrow_layout else 24)
	frame.add_theme_constant_override("margin_top", 12)
	frame.add_theme_constant_override("margin_right", 8 if narrow_layout else 24)
	frame.add_theme_constant_override("margin_bottom", 12)
	scroll.add_child(frame)

	var content_width := minf(viewport_size.x - (36.0 if narrow_layout else 96.0), 760.0)
	var content_box := CenterContainer.new()
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_child(content_box)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(maxf(0.0, content_width), 0.0)
	column.add_theme_constant_override("separation", 12 if narrow_layout else 16)
	content_box.add_child(column)

	var title := Label.new()
	title.text = "RAIDEN PROTOTYPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 31 if narrow_layout else 42)
	title.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	column.add_child(title)

	var tag := Label.new()
	tag.text = _t("PUBLIC DEMO // RC-0.4", "PUBLIC DEMO // RC-0.4")
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag.add_theme_font_size_override("font_size", 15 if narrow_layout else 20)
	tag.add_theme_color_override("font_color", Color(1.0, 0.84, 0.46))
	column.add_child(tag)

	var hero_panel := PanelContainer.new()
	hero_panel.add_theme_stylebox_override("panel", _showcase_card_style(Color(0.96, 0.76, 0.34), true))
	column.add_child(hero_panel)

	var hero_box := VBoxContainer.new()
	hero_box.add_theme_constant_override("separation", 9)
	hero_panel.add_child(hero_box)

	var hero_title := Label.new()
	hero_title.text = _t("双阶段纵版射击展示", "Vertical Shooter Showcase")
	hero_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_title.add_theme_font_size_override("font_size", 22 if narrow_layout else 28)
	hero_title.add_theme_color_override("font_color", Color(0.99, 0.99, 1.0))
	hero_box.add_child(hero_title)

	var summary := Label.new()
	summary.text = _t(
		"一局穿过成长、炸弹救场、风暴机关、Boss 高潮和结算总结。",
		"One route covers growth, bomb saves, storm hazards, boss pressure and debrief."
	)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 16 if narrow_layout else 20)
	summary.add_theme_color_override("font_color", Color(0.82, 0.90, 0.98))
	hero_box.add_child(summary)

	hero_box.add_child(_build_chip_row([
		_t("2 关路线", "2 Stages"),
		_t("自动射击", "Auto Fire"),
		_t("Boss 收束", "Boss Route"),
	], Color(0.58, 0.88, 1.0)))

	var chapter_button := Button.new()
	chapter_button.text = "%s\n%s" % [
		_t("开始完整 Demo", "Start Full Demo"),
		_t("推荐路线：Stage 01 -> Stage 02", "Recommended Route: Stage 01 -> Stage 02")
	]
	chapter_button.custom_minimum_size = Vector2(0, 86 if narrow_layout else 96)
	chapter_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiButtonStyle.apply(chapter_button, Color(0.96, 0.76, 0.34), true)
	chapter_button.pressed.connect(RunState.start_chapter)
	hero_box.add_child(chapter_button)

	var first_time_label := Label.new()
	first_time_label.text = _t(
		"移动躲弹即可，射击自动进行。炸弹：Space / Shift / X。",
		"Move and dodge; shooting is automatic. Bomb: Space / Shift / X."
	)
	first_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	first_time_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	first_time_label.add_theme_font_size_override("font_size", 14 if narrow_layout else 17)
	first_time_label.add_theme_color_override("font_color", Color(0.76, 0.84, 0.94))
	hero_box.add_child(first_time_label)

	var practice_label := Label.new()
	practice_label.text = _t("练习入口（可选）", "Practice Routes (Optional)")
	practice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	practice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	practice_label.add_theme_font_size_override("font_size", 14 if narrow_layout else 18)
	practice_label.add_theme_color_override("font_color", Color(0.78, 0.88, 1.0))
	column.add_child(practice_label)

	var stage_button_row := GridContainer.new()
	stage_button_row.columns = 2
	stage_button_row.add_theme_constant_override("h_separation", 8 if narrow_layout else 12)
	stage_button_row.add_theme_constant_override("v_separation", 8 if narrow_layout else 12)
	column.add_child(stage_button_row)

	for stage_id in ["stage_1", "stage_2"]:
		var meta := StageCatalog.get_stage_meta(stage_id)
		var button := Button.new()
		button.text = "%s\n%s" % [
			_get_stage_menu_label(stage_id, meta),
			_get_stage_tagline(stage_id, meta)
		]
		button.custom_minimum_size = Vector2(0, 66 if narrow_layout else 76)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 14 if narrow_layout else 16)
		UiButtonStyle.apply(button, Color(0.58, 0.88, 1.0), false)
		button.pressed.connect(RunState.start_game.bind(stage_id))
		stage_button_row.add_child(button)

	column.add_child(_build_settings_panel(narrow_layout))

	var demo_panel := PanelContainer.new()
	demo_panel.add_theme_stylebox_override("panel", _showcase_card_style(Color(0.58, 0.88, 1.0), false))
	column.add_child(demo_panel)

	var demo_margin := MarginContainer.new()
	demo_margin.add_theme_constant_override("margin_left", 12)
	demo_margin.add_theme_constant_override("margin_top", 8)
	demo_margin.add_theme_constant_override("margin_right", 12)
	demo_margin.add_theme_constant_override("margin_bottom", 8)
	demo_panel.add_child(demo_margin)

	var demo_label := Label.new()
	demo_label.text = _t(
		"展品状态：完整 Demo 是当前推荐试玩路线。Stage 01 负责成长节奏，Stage 02 负责风暴机关与 Boss 收束。",
		"Exhibit status: Full Demo is the recommended route. Stage 01 builds growth; Stage 02 closes with storm hazards and boss pressure."
	)
	demo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	demo_label.add_theme_font_size_override("font_size", 13 if narrow_layout else 16)
	demo_label.add_theme_color_override("font_color", Color(0.76, 0.84, 0.94))
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
		last_sortie.add_theme_font_size_override("font_size", 14 if narrow_layout else 17)
		column.add_child(last_sortie)

	var hint := Label.new()
	hint.text = _t(
		"移动：WASD / 方向键    炸弹：Space / Shift / X    暂停：Esc / P    重开：R",
		"Move: WASD / Arrows    Bomb: Space / Shift / X    Pause: Esc / P    Retry: R"
	)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 13 if narrow_layout else 16)
	hint.add_theme_color_override("font_color", Color(0.70, 0.78, 0.88))
	column.add_child(hint)


func _build_chip_row(chip_texts: Array, accent: Color) -> Control:
	var row := GridContainer.new()
	row.columns = 3
	row.add_theme_constant_override("h_separation", 6)
	row.add_theme_constant_override("v_separation", 6)
	for chip_text in chip_texts:
		var chip := PanelContainer.new()
		chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chip.add_theme_stylebox_override("panel", _chip_style(accent))

		var label := Label.new()
		label.text = String(chip_text)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0))
		chip.add_child(label)
		row.add_child(chip)
	return row


func _showcase_card_style(accent: Color, prominent: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.13, 0.98).lerp(accent, 0.10 if prominent else 0.05)
	style.border_color = accent
	style.border_width_left = 2 if prominent else 1
	style.border_width_top = 2 if prominent else 1
	style.border_width_right = 2 if prominent else 1
	style.border_width_bottom = 2 if prominent else 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 14.0
	style.content_margin_top = 12.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 12.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.24)
	style.shadow_size = 10 if prominent else 4
	style.shadow_offset = Vector2(0.0, 4.0)
	return style


func _chip_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.13, 0.19, 0.96).lerp(accent, 0.14)
	style.border_color = accent.darkened(0.08)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 8.0
	style.content_margin_top = 5.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 5.0
	return style


func _build_settings_panel(narrow_layout: bool) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _showcase_card_style(Color(0.68, 0.78, 1.0), false))

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
