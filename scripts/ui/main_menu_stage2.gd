extends Control

const StageCatalog := preload("res://scripts/game/stage_catalog.gd")


func _ready() -> void:
	_build_ui()
	if RunState.is_autoplay():
		call_deferred("_auto_start")


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.03, 0.04, 0.1)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var stripe := ColorRect.new()
	stripe.color = Color(0.08, 0.16, 0.28, 0.92)
	stripe.set_anchors_preset(Control.PRESET_TOP_WIDE)
	stripe.offset_top = 90.0
	stripe.offset_bottom = 290.0
	add_child(stripe)

	var content_width := clampf(get_viewport_rect().size.x - 260.0, 620.0, 860.0)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.offset_left = -content_width * 0.5
	column.offset_top = -320
	column.offset_right = content_width * 0.5
	column.offset_bottom = 320
	column.add_theme_constant_override("separation", 18)
	add_child(column)

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
	chinese_button.pressed.connect(func() -> void:
		RunState.set_language_code("zh_CN")
		get_tree().reload_current_scene()
	)
	settings_row.add_child(chinese_button)

	var english_button := Button.new()
	english_button.text = "English"
	english_button.custom_minimum_size = Vector2(110, 40)
	english_button.disabled = RunState.get_language_code() == "en"
	english_button.pressed.connect(func() -> void:
		RunState.set_language_code("en")
		get_tree().reload_current_scene()
	)
	settings_row.add_child(english_button)

	var title := Label.new()
	title.text = "RAIDEN PROTOTYPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	column.add_child(title)

	var tag := Label.new()
	tag.text = _t("双关纵版切片候选", "DUAL-STAGE VERTICAL SLICE CANDIDATE")
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag.add_theme_font_size_override("font_size", 24)
	column.add_child(tag)

	var summary := Label.new()
	summary.text = _t(
		"Stage 01 是当前更完整的开场展示关。\nStage 02 已经把风暴机关、Boss 路线和章节收束接成一条完整链路。",
		"Stage 01 is the polished opener.\nStage 02 now carries storm hazards through the boss route and chapter ending flow."
	)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 22)
	column.add_child(summary)

	var build_panel := PanelContainer.new()
	column.add_child(build_panel)

	var build_margin := MarginContainer.new()
	build_margin.add_theme_constant_override("margin_left", 12)
	build_margin.add_theme_constant_override("margin_top", 10)
	build_margin.add_theme_constant_override("margin_right", 12)
	build_margin.add_theme_constant_override("margin_bottom", 10)
	build_panel.add_child(build_margin)

	var build_column := VBoxContainer.new()
	build_column.add_theme_constant_override("separation", 4)
	build_margin.add_child(build_column)

	var build_title := Label.new()
	build_title.text = RunState.get_build_badge()
	build_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_title.add_theme_font_size_override("font_size", 18)
	build_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	build_column.add_child(build_title)

	var build_summary := Label.new()
	build_summary.text = RunState.get_build_summary()
	build_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	build_summary.add_theme_font_size_override("font_size", 18)
	build_column.add_child(build_summary)

	var chapter_button := Button.new()
	chapter_button.text = "%s\n%s\nStage 01 -> Stage 02\n%s" % [
		_t("章节连打", "Chapter Run"),
		_t("推荐演示入口", "Recommended Demo Route"),
		RunState.get_release_candidate_label()
	]
	chapter_button.custom_minimum_size = Vector2(360, 96)
	chapter_button.pressed.connect(RunState.start_chapter)
	column.add_child(chapter_button)

	var stage_button_row := HBoxContainer.new()
	stage_button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stage_button_row.add_theme_constant_override("separation", 12)
	column.add_child(stage_button_row)

	for stage_id in ["stage_1", "stage_2"]:
		var meta := StageCatalog.get_stage_meta(stage_id)
		var button := Button.new()
		button.text = "%s\n%s" % [
			_get_stage_menu_label(stage_id, meta),
			_get_stage_tagline(stage_id, meta)
		]
		button.custom_minimum_size = Vector2(220, 72)
		button.pressed.connect(RunState.start_game.bind(stage_id))
		stage_button_row.add_child(button)

	var features := Label.new()
	features.text = _t(
		"当前版本状态：\n- Stage 01：负责成长、炸弹时机和章节交接\n- Stage 02：负责风暴机关、Boss 压迫和终盘收束\n- Chapter Run：已具备 Briefing、Ending、Debrief 的完整双关展示链路",
		"Current build status:\n- Stage 01: showcase opener with clean growth and chapter handoff\n- Stage 02: enemy, environment and boss hazards now sync into one storm route\n- Chapter Run: includes Briefing, Ending and Debrief as a full two-stage presentation chain"
	)
	features.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	features.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	features.add_theme_font_size_override("font_size", 18)
	column.add_child(features)

	var assessment := Label.new()
	assessment.text = _t(
		"判断：\n- 当前版本已经接近双关垂直切片候选\n- 更适合做最终包装与资源替换，而不是继续默认扩系统",
		"Assessment:\n- This build now behaves like a dual-stage vertical-slice candidate\n- Best next step is either slice polish and final packaging, or a deliberate expansion into a fuller chapter pipeline"
	)
	assessment.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	assessment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	assessment.add_theme_font_size_override("font_size", 17)
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
	demo_label.add_theme_font_size_override("font_size", 17)
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
		last_sortie.add_theme_font_size_override("font_size", 18)
		column.add_child(last_sortie)

	var hint := Label.new()
	hint.text = _t(
		"移动：WASD / 方向键\n炸弹：Space / Shift / X\n暂停：Esc / P    重开：R",
		"Move: WASD / Arrows\nBomb: Space / Shift / X\nPause: Esc / P    Restart: R"
	)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 18)
	column.add_child(hint)


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
	if stage_id == "stage_1":
		return "第一关"
	if stage_id == "stage_2":
		return "第二关"
	return String(meta.get("menu_label", stage_id))


func _get_stage_tagline(stage_id: String, meta: Dictionary) -> String:
	if RunState.is_english():
		return String(meta.get("tagline", ""))
	if stage_id == "stage_1":
		return "建立成长与开场节奏"
	if stage_id == "stage_2":
		return "风暴机关与Boss高潮"
	return String(meta.get("tagline", ""))
