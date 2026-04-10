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
var stage_label: Label
var banner_label: Label
var fire_bar: ProgressBar
var boss_panel: PanelContainer
var boss_name_label: Label
var boss_phase_label: Label
var boss_bar: ProgressBar
var pause_panel: PanelContainer


func _ready() -> void:
	layer = 10
	_build_status_panel()
	_build_boss_panel()
	_build_banner()
	_build_pause_panel()
	_build_hint_label()


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

	var right_column := VBoxContainer.new()
	right_column.custom_minimum_size = Vector2(180.0, 0.0)
	right_column.add_theme_constant_override("separation", 6)
	row.add_child(right_column)

	hull_label = _make_label("HULL 3")
	fire_label = _make_label("FIRE Lv1 / 5")
	bomb_label = _make_label("BOMBS 2 / 4 [**--]")
	bomb_hint_label = _make_label("READY TO BOMB")
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


func _build_bomb_string(bombs: int) -> String:
	var parts: Array[String] = []
	for slot in range(4):
		parts.append("*" if slot < bombs else "-")
	return "".join(parts)


func set_stage_text(text: String) -> void:
	stage_label.text = text


func show_banner(text: String, color: Color = Color(1.0, 1.0, 1.0)) -> void:
	banner_label.text = text
	banner_label.add_theme_color_override("font_color", color)
	banner_label.visible = true


func hide_banner() -> void:
	banner_label.visible = false


func set_boss_info(name: String, ratio: float, phase_text: String = "") -> void:
	boss_panel.visible = true
	boss_name_label.text = name
	boss_phase_label.text = phase_text
	boss_bar.value = clamp(ratio, 0.0, 1.0)


func hide_boss() -> void:
	boss_panel.visible = false


func show_pause_menu() -> void:
	pause_panel.visible = true


func hide_pause_menu() -> void:
	pause_panel.visible = false


func is_pause_menu_visible() -> bool:
	return pause_panel.visible
