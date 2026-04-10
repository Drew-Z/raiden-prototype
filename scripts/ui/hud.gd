extends CanvasLayer
class_name BattleHUD

var score_label: Label
var lives_label: Label
var fire_label: Label
var bomb_label: Label
var banner_label: Label
var boss_panel: PanelContainer
var boss_name_label: Label
var boss_bar: ProgressBar


func _ready() -> void:
	var top_panel := PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 16.0
	top_panel.offset_top = 16.0
	top_panel.offset_right = -16.0
	top_panel.offset_bottom = 112.0
	add_child(top_panel)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 14)
	top_margin.add_theme_constant_override("margin_top", 12)
	top_margin.add_theme_constant_override("margin_right", 14)
	top_margin.add_theme_constant_override("margin_bottom", 12)
	top_panel.add_child(top_margin)

	var stats_column := VBoxContainer.new()
	stats_column.add_theme_constant_override("separation", 6)
	top_margin.add_child(stats_column)

	score_label = _make_label("Score 000000")
	lives_label = _make_label("Lives 3")
	fire_label = _make_label("Fire Lv1")
	bomb_label = _make_label("Bombs 2")
	stats_column.add_child(score_label)
	stats_column.add_child(lives_label)
	stats_column.add_child(fire_label)
	stats_column.add_child(bomb_label)

	boss_panel = PanelContainer.new()
	boss_panel.visible = false
	boss_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_panel.offset_left = 16.0
	boss_panel.offset_top = 126.0
	boss_panel.offset_right = -16.0
	boss_panel.offset_bottom = 188.0
	add_child(boss_panel)

	var boss_margin := MarginContainer.new()
	boss_margin.add_theme_constant_override("margin_left", 12)
	boss_margin.add_theme_constant_override("margin_top", 10)
	boss_margin.add_theme_constant_override("margin_right", 12)
	boss_margin.add_theme_constant_override("margin_bottom", 10)
	boss_panel.add_child(boss_margin)

	var boss_column := VBoxContainer.new()
	boss_column.add_theme_constant_override("separation", 8)
	boss_margin.add_child(boss_column)

	boss_name_label = _make_label("BOSS")
	boss_bar = ProgressBar.new()
	boss_bar.min_value = 0.0
	boss_bar.max_value = 1.0
	boss_bar.value = 1.0
	boss_bar.show_percentage = false
	boss_bar.custom_minimum_size = Vector2(0, 18)
	boss_column.add_child(boss_name_label)
	boss_column.add_child(boss_bar)

	banner_label = Label.new()
	banner_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner_label.offset_top = 220.0
	banner_label.offset_left = -180.0
	banner_label.offset_right = 180.0
	banner_label.offset_bottom = 270.0
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 30)
	banner_label.visible = false
	add_child(banner_label)


func _make_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	return label


func update_player(lives: int, fire_level: int, bombs: int, score: int) -> void:
	score_label.text = "Score %06d" % score
	lives_label.text = "Lives %d" % lives
	fire_label.text = "Fire Lv%d" % fire_level
	bomb_label.text = "Bombs %d" % bombs


func show_banner(text: String) -> void:
	banner_label.text = text
	banner_label.visible = true


func hide_banner() -> void:
	banner_label.visible = false


func set_boss_info(name: String, ratio: float) -> void:
	boss_panel.visible = true
	boss_name_label.text = name
	boss_bar.value = clamp(ratio, 0.0, 1.0)


func hide_boss() -> void:
	boss_panel.visible = false
