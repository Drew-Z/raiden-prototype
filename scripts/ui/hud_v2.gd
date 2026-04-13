extends CanvasLayer
class_name BattleHUDV2

signal resume_requested
signal restart_requested
signal menu_requested

var score_label: Label
var hull_label: Label
var fire_label: Label
var bomb_label: Label
var bomb_hint_label: Label
var status_label: Label
var stage_label: Label
var banner_label: Label
var fire_bar: ProgressBar
var stage_bar: ProgressBar
var boss_panel: PanelContainer
var boss_name_label: Label
var boss_phase_label: Label
var boss_bar: ProgressBar
var event_panel: PanelContainer
var event_title_label: Label
var event_detail_label: Label
var pause_panel: PanelContainer
var pulse_overlay: ColorRect
var danger_overlay: ColorRect
var clear_panel: PanelContainer
var clear_title_label: Label
var clear_stats_label: Label
var event_card_token := 0
var left_warning_label: Label
var right_warning_label: Label
var left_warning_token := 0
var right_warning_token := 0
var cinematic_top_bar: ColorRect
var cinematic_bottom_bar: ColorRect


func _ready() -> void:
	layer = 10
	_build_status_panel()
	_build_boss_panel()
	_build_banner()
	_build_pulse_overlay()
	_build_danger_overlay()
	_build_event_panel()
	_build_pause_panel()
	_build_hint_label()
	_build_clear_panel()
	_build_edge_warnings()
	_build_cinematic_bars()


func _build_status_panel() -> void:
	var top_panel := PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 14.0
	top_panel.offset_top = 14.0
	top_panel.offset_right = -14.0
	top_panel.offset_bottom = 126.0
	add_child(top_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	top_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var left_column := VBoxContainer.new()
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_theme_constant_override("separation", 4)
	row.add_child(left_column)

	stage_label = Label.new()
	stage_label.text = "PHASE 2 DEMO"
	stage_label.add_theme_font_size_override("font_size", 20)
	left_column.add_child(stage_label)

	score_label = Label.new()
	score_label.text = "SCORE 000000"
	score_label.add_theme_font_size_override("font_size", 28)
	left_column.add_child(score_label)

	stage_bar = ProgressBar.new()
	stage_bar.min_value = 0.0
	stage_bar.max_value = 1.0
	stage_bar.value = 0.0
	stage_bar.show_percentage = false
	stage_bar.custom_minimum_size = Vector2(0.0, 10.0)
	left_column.add_child(stage_bar)

	var right_column := VBoxContainer.new()
	right_column.custom_minimum_size = Vector2(180.0, 0.0)
	right_column.add_theme_constant_override("separation", 6)
	row.add_child(right_column)

	hull_label = _make_label("HULL 3")
	fire_label = _make_label("FIRE Lv1 / 5")
	bomb_label = _make_label("BOMBS 2 / 4 [**--]")
	bomb_hint_label = _make_label("READY TO BOMB")
	status_label = _make_label("BUILD FIREPOWER")
	fire_bar = ProgressBar.new()
	fire_bar.min_value = 1.0
	fire_bar.max_value = 5.0
	fire_bar.value = 1.0
	fire_bar.show_percentage = false
	fire_bar.custom_minimum_size = Vector2(0.0, 14.0)

	right_column.add_child(hull_label)
	right_column.add_child(fire_label)
	right_column.add_child(fire_bar)
	right_column.add_child(bomb_label)
	right_column.add_child(bomb_hint_label)
	right_column.add_child(status_label)


func _build_boss_panel() -> void:
	boss_panel = PanelContainer.new()
	boss_panel.visible = false
	boss_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_panel.offset_left = 14.0
	boss_panel.offset_top = 136.0
	boss_panel.offset_right = -14.0
	boss_panel.offset_bottom = 210.0
	add_child(boss_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	boss_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	column.add_child(title_row)

	boss_name_label = _make_label("BOSS")
	boss_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boss_phase_label = _make_label("PHASE 1")
	title_row.add_child(boss_name_label)
	title_row.add_child(boss_phase_label)

	boss_bar = ProgressBar.new()
	boss_bar.min_value = 0.0
	boss_bar.max_value = 1.0
	boss_bar.value = 1.0
	boss_bar.show_percentage = false
	boss_bar.custom_minimum_size = Vector2(0.0, 20.0)
	column.add_child(boss_bar)


func _build_banner() -> void:
	banner_label = Label.new()
	banner_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner_label.offset_top = 236.0
	banner_label.offset_left = -220.0
	banner_label.offset_right = 220.0
	banner_label.offset_bottom = 286.0
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 28)
	banner_label.visible = false
	add_child(banner_label)


func _build_event_panel() -> void:
	event_panel = PanelContainer.new()
	event_panel.visible = false
	event_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	event_panel.offset_left = -220.0
	event_panel.offset_top = 300.0
	event_panel.offset_right = 220.0
	event_panel.offset_bottom = 388.0
	add_child(event_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	event_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)

	event_title_label = Label.new()
	event_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_title_label.add_theme_font_size_override("font_size", 24)
	column.add_child(event_title_label)

	event_detail_label = Label.new()
	event_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_detail_label.add_theme_font_size_override("font_size", 16)
	column.add_child(event_detail_label)


func _build_pulse_overlay() -> void:
	pulse_overlay = ColorRect.new()
	pulse_overlay.visible = false
	pulse_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(pulse_overlay)


func _build_danger_overlay() -> void:
	danger_overlay = ColorRect.new()
	danger_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	danger_overlay.color = Color(1.0, 0.26, 0.18, 0.0)
	danger_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(danger_overlay)


func _build_pause_panel() -> void:
	pause_panel = PanelContainer.new()
	pause_panel.visible = false
	pause_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_panel.offset_left = -170.0
	pause_panel.offset_top = -140.0
	pause_panel.offset_right = 170.0
	pause_panel.offset_bottom = 140.0
	add_child(pause_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	pause_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Resume the run, restart instantly,\nor return to the main menu."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	column.add_child(subtitle)

	var resume_button := Button.new()
	resume_button.text = "Resume"
	resume_button.custom_minimum_size = Vector2(190.0, 46.0)
	resume_button.pressed.connect(func() -> void:
		resume_requested.emit()
	)
	column.add_child(resume_button)

	var restart_button := Button.new()
	restart_button.text = "Restart"
	restart_button.custom_minimum_size = Vector2(190.0, 46.0)
	restart_button.pressed.connect(func() -> void:
		restart_requested.emit()
	)
	column.add_child(restart_button)

	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(190.0, 44.0)
	menu_button.pressed.connect(func() -> void:
		menu_requested.emit()
	)
	column.add_child(menu_button)


func _build_clear_panel() -> void:
	clear_panel = PanelContainer.new()
	clear_panel.visible = false
	clear_panel.set_anchors_preset(Control.PRESET_CENTER)
	clear_panel.offset_left = -210.0
	clear_panel.offset_top = -96.0
	clear_panel.offset_right = 210.0
	clear_panel.offset_bottom = 96.0
	add_child(clear_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	clear_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	clear_title_label = Label.new()
	clear_title_label.text = "AREA SECURED"
	clear_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_title_label.add_theme_font_size_override("font_size", 28)
	column.add_child(clear_title_label)

	clear_stats_label = Label.new()
	clear_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_stats_label.add_theme_font_size_override("font_size", 18)
	column.add_child(clear_stats_label)


func _build_hint_label() -> void:
	var hint := Label.new()
	hint.text = "ESC Pause   R Restart   Space Bomb"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_left = 12.0
	hint.offset_right = -12.0
	hint.offset_top = -30.0
	hint.offset_bottom = -6.0
	add_child(hint)


func _build_edge_warnings() -> void:
	left_warning_label = Label.new()
	left_warning_label.visible = false
	left_warning_label.text = "<< INBOUND"
	left_warning_label.rotation = -PI * 0.5
	left_warning_label.add_theme_font_size_override("font_size", 22)
	left_warning_label.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	left_warning_label.offset_left = -34.0
	left_warning_label.offset_right = 46.0
	left_warning_label.offset_top = 330.0
	left_warning_label.offset_bottom = 520.0
	add_child(left_warning_label)

	right_warning_label = Label.new()
	right_warning_label.visible = false
	right_warning_label.text = "INBOUND >>"
	right_warning_label.rotation = PI * 0.5
	right_warning_label.add_theme_font_size_override("font_size", 22)
	right_warning_label.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	right_warning_label.offset_left = -46.0
	right_warning_label.offset_right = 34.0
	right_warning_label.offset_top = 330.0
	right_warning_label.offset_bottom = 520.0
	add_child(right_warning_label)


func _build_cinematic_bars() -> void:
	cinematic_top_bar = ColorRect.new()
	cinematic_top_bar.color = Color(0.0, 0.0, 0.0, 0.92)
	cinematic_top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	cinematic_top_bar.offset_bottom = 0.0
	add_child(cinematic_top_bar)

	cinematic_bottom_bar = ColorRect.new()
	cinematic_bottom_bar.color = Color(0.0, 0.0, 0.0, 0.92)
	cinematic_bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	cinematic_bottom_bar.offset_top = 0.0
	add_child(cinematic_bottom_bar)


func _make_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	return label


func update_player(lives: int, fire_level: int, bombs: int, score: int) -> void:
	score_label.text = "SCORE %06d" % score
	hull_label.text = "HULL %d / 3" % lives
	fire_label.text = "FIRE Lv%d / 5" % fire_level
	fire_bar.value = fire_level
	fire_bar.modulate = Color(0.58, 0.92, 1.0) if fire_level >= 4 else Color(0.84, 0.88, 1.0)
	bomb_label.text = "BOMBS %d / 4 [%s]" % [bombs, _build_bomb_string(bombs)]
	bomb_hint_label.text = "READY TO BOMB" if bombs > 0 else "NO BOMB STOCK"
	bomb_hint_label.add_theme_color_override("font_color", Color(1.0, 0.76, 0.34) if bombs > 0 else Color(0.72, 0.72, 0.72))
	fire_label.add_theme_color_override("font_color", Color(0.5, 0.92, 1.0) if fire_level >= 4 else Color(1.0, 1.0, 1.0))
	hull_label.add_theme_color_override("font_color", Color(1.0, 0.54, 0.46) if lives <= 1 else Color(1.0, 1.0, 1.0))
	stage_bar.modulate = Color(1.0, 0.78, 0.38) if fire_level >= 4 else Color(0.55, 0.84, 1.0)


func _build_bomb_string(bombs: int) -> String:
	var parts: Array[String] = []
	for slot in range(4):
		parts.append("*" if slot < bombs else "-")
	return "".join(parts)


func set_stage_text(text: String) -> void:
	stage_label.text = text


func set_stage_progress(ratio: float) -> void:
	stage_bar.value = clampf(ratio, 0.0, 1.0)


func set_status_hint(text: String, color: Color = Color(0.88, 0.94, 1.0)) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)


func show_banner(text: String, color: Color = Color(1.0, 1.0, 1.0)) -> void:
	banner_label.text = text
	banner_label.add_theme_color_override("font_color", color)
	banner_label.visible = true


func show_event_card(title_text: String, detail_text: String, color: Color = Color(1.0, 0.86, 0.54)) -> void:
	event_card_token += 1
	event_title_label.text = title_text
	event_title_label.add_theme_color_override("font_color", color)
	event_detail_label.text = detail_text
	event_panel.visible = true


func show_event_card_temporarily(title_text: String, detail_text: String, duration: float, color: Color = Color(1.0, 0.86, 0.54)) -> void:
	show_event_card(title_text, detail_text, color)
	var current_token := event_card_token
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if current_token == event_card_token:
			hide_event_card()
	)


func hide_event_card() -> void:
	event_panel.visible = false


func hide_banner() -> void:
	banner_label.visible = false


func set_boss_info(name: String, ratio: float, phase_text: String = "") -> void:
	boss_panel.visible = true
	boss_name_label.text = name
	boss_phase_label.text = phase_text
	boss_bar.value = clamp(ratio, 0.0, 1.0)
	boss_bar.modulate = Color(1.0, 0.56, 0.34) if ratio <= 0.33 else Color(1.0, 0.74, 0.4)


func pulse_screen(color: Color, duration: float = 0.08) -> void:
	if not is_instance_valid(pulse_overlay):
		return
	pulse_overlay.color = color
	pulse_overlay.visible = true
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if is_instance_valid(pulse_overlay):
			pulse_overlay.visible = false
	)


func set_danger_overlay(strength: float, color: Color = Color(1.0, 0.28, 0.18, 1.0)) -> void:
	if not is_instance_valid(danger_overlay):
		return
	danger_overlay.color = Color(color.r, color.g, color.b, clampf(strength, 0.0, 0.22))


func show_clear_summary(title_text: String, detail_text: String, color: Color = Color(1.0, 0.92, 0.62)) -> void:
	clear_title_label.text = title_text
	clear_title_label.add_theme_color_override("font_color", color)
	clear_stats_label.text = detail_text
	clear_panel.visible = true


func hide_clear_summary() -> void:
	clear_panel.visible = false


func show_edge_warning(side: String, text: String, duration: float = 0.75, color: Color = Color(1.0, 0.76, 0.4)) -> void:
	var label := left_warning_label
	if side == "right":
		label = right_warning_label
	if not is_instance_valid(label):
		return

	if side == "right":
		right_warning_token += 1
		label.text = "%s >>" % text
	else:
		left_warning_token += 1
		label.text = "<< %s" % text
	label.add_theme_color_override("font_color", color)
	label.visible = true

	var current_token := right_warning_token if side == "right" else left_warning_token
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		var active_token := right_warning_token if side == "right" else left_warning_token
		if active_token == current_token and is_instance_valid(label):
			label.visible = false
	)


func show_cinematic_bars(height: float = 42.0, duration: float = 0.18) -> void:
	if not is_instance_valid(cinematic_top_bar) or not is_instance_valid(cinematic_bottom_bar):
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(cinematic_top_bar, "offset_bottom", height, duration)
	tween.tween_property(cinematic_bottom_bar, "offset_top", -height, duration)


func hide_cinematic_bars(duration: float = 0.18) -> void:
	if not is_instance_valid(cinematic_top_bar) or not is_instance_valid(cinematic_bottom_bar):
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(cinematic_top_bar, "offset_bottom", 0.0, duration)
	tween.tween_property(cinematic_bottom_bar, "offset_top", 0.0, duration)


func hide_boss() -> void:
	boss_panel.visible = false


func show_pause_menu() -> void:
	pause_panel.visible = true


func hide_pause_menu() -> void:
	pause_panel.visible = false


func is_pause_menu_visible() -> bool:
	return pause_panel.visible
