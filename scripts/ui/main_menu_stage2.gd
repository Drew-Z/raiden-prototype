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

	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.offset_left = -200
	column.offset_top = -280
	column.offset_right = 200
	column.offset_bottom = 260
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 18)
	add_child(column)

	var title := Label.new()
	title.text = "RAIDEN PROTOTYPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	column.add_child(title)

	var tag := Label.new()
	tag.text = "DUAL-STAGE VERTICAL SLICE CANDIDATE"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 24)
	column.add_child(tag)

	var summary := Label.new()
	summary.text = "Stage 01 is the polished opener.\nStage 02 now carries storm hazards through the boss route and chapter ending flow."
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
	chapter_button.text = "Chapter Run\nStage 01 -> Stage 02\n%s" % RunState.get_release_candidate_label()
	chapter_button.custom_minimum_size = Vector2(320, 74)
	chapter_button.pressed.connect(RunState.start_chapter)
	column.add_child(chapter_button)

	var stage_button_row := HBoxContainer.new()
	stage_button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stage_button_row.add_theme_constant_override("separation", 12)
	column.add_child(stage_button_row)

	for stage_id in ["stage_1", "stage_2"]:
		var meta := StageCatalog.get_stage_meta(stage_id)
		var button := Button.new()
		button.text = "%s\n%s" % [meta.menu_label, meta.tagline]
		button.custom_minimum_size = Vector2(220, 72)
		button.pressed.connect(RunState.start_game.bind(stage_id))
		stage_button_row.add_child(button)

	var features := Label.new()
	features.text = "Current build status:\n- Stage 01: showcase opener with clean growth and chapter handoff\n- Stage 02: enemy, environment and boss hazards now sync into one storm route\n- Chapter Run: includes Briefing, Ending and Debrief as a full two-stage presentation chain"
	features.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	features.add_theme_font_size_override("font_size", 18)
	column.add_child(features)

	var assessment := Label.new()
	assessment.text = "Assessment:\n- This build now behaves like a dual-stage vertical-slice candidate\n- Best next step is either slice polish and final packaging, or a deliberate expansion into a fuller chapter pipeline"
	assessment.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
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
		last_sortie.text = "Last Sortie:\nGrade %s   Final %06d\nKill %.0f%%   Max Fire Lv%d" % [
			RunState.get_performance_grade(),
			RunState.current_run.final_score,
			RunState.get_kill_rate(),
			RunState.current_run.max_fire_level
		]
		last_sortie.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		last_sortie.add_theme_font_size_override("font_size", 18)
		column.add_child(last_sortie)

	var hint := Label.new()
	hint.text = "Move: WASD / Arrows\nBomb: Space / Shift / X\nPause: Esc / P    Restart: R"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	column.add_child(hint)


func _auto_start() -> void:
	if RunState.wants_autoplay_chapter():
		RunState.start_chapter()
	else:
		RunState.start_game(RunState.get_requested_autoplay_stage())
