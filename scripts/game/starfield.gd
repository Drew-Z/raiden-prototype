extends Node2D
class_name Starfield

var scroll := 0.0
var speed := 140.0
var screen_size := Vector2(540, 960)
var stars: Array[Dictionary] = []
var theme_id := "stage_1"
var flash_timer := 0.0
var flash_alpha := 0.0
var base_color := Color(0.03, 0.05, 0.11)
var top_glow_color := Color(0.08, 0.13, 0.2, 0.24)
var bottom_glow_color := Color(0.02, 0.08, 0.14, 0.28)
var lane_color := Color(0.1, 0.16, 0.25, 0.55)
var stripe_color := Color(0.07, 0.2, 0.29, 0.42)
var band_color := Color(0.05, 0.16, 0.24, 0.1)
var star_color := Color(0.86, 0.95, 1.0, 0.88)


func _ready() -> void:
	for _index in range(24):
		stars.append({
			"position": Vector2(randf() * screen_size.x, randf() * screen_size.y),
			"size": randf_range(1.0, 3.0),
			"speed": randf_range(0.55, 1.45)
		})
	_apply_theme()


func configure(stage_theme_id: String) -> Starfield:
	theme_id = stage_theme_id
	_apply_theme()
	return self


func _apply_theme() -> void:
	if theme_id == "stage_2":
		base_color = Color(0.03, 0.04, 0.08)
		top_glow_color = Color(0.1, 0.16, 0.26, 0.32)
		bottom_glow_color = Color(0.08, 0.12, 0.2, 0.32)
		lane_color = Color(0.14, 0.18, 0.28, 0.58)
		stripe_color = Color(0.08, 0.16, 0.32, 0.34)
		band_color = Color(0.12, 0.18, 0.3, 0.14)
		star_color = Color(0.82, 0.9, 1.0, 0.9)
	else:
		base_color = Color(0.03, 0.05, 0.11)
		top_glow_color = Color(0.08, 0.13, 0.2, 0.24)
		bottom_glow_color = Color(0.02, 0.08, 0.14, 0.28)
		lane_color = Color(0.1, 0.16, 0.25, 0.55)
		stripe_color = Color(0.07, 0.2, 0.29, 0.42)
		band_color = Color(0.05, 0.16, 0.24, 0.1)
		star_color = Color(0.86, 0.95, 1.0, 0.88)


func _process(delta: float) -> void:
	scroll = fmod(scroll + speed * delta, 80.0)
	flash_timer = max(flash_timer - delta, 0.0)
	flash_alpha = max(flash_alpha - delta * 1.8, 0.0)
	if theme_id == "stage_2" and flash_timer <= 0.0 and randf() < 0.016:
		flash_timer = randf_range(1.6, 2.8)
		flash_alpha = randf_range(0.08, 0.16)
	for star in stars:
		var next_position: Vector2 = star.position
		next_position.y += speed * star.speed * delta
		if next_position.y > screen_size.y:
			next_position.y = -8.0
			next_position.x = randf() * screen_size.x
		star.position = next_position
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, screen_size), base_color, true)
	draw_rect(Rect2(Vector2(0, 0), Vector2(screen_size.x, 160.0)), top_glow_color, true)
	draw_rect(Rect2(Vector2(0, screen_size.y - 220.0), Vector2(screen_size.x, 220.0)), bottom_glow_color, true)

	for lane in range(4):
		var x := 40.0 + lane * ((screen_size.x - 80.0) / 3.0)
		draw_line(Vector2(x, 0), Vector2(x, screen_size.y), lane_color, 2.0)
		draw_line(Vector2(x + 8.0, 0), Vector2(x + 8.0, screen_size.y), Color(0.16, 0.26, 0.36, 0.16), 1.0)

	for stripe in range(14):
		var top := fmod(stripe * 80.0 + scroll, screen_size.y + 80.0) - 80.0
		draw_rect(Rect2(Vector2(0, top), Vector2(screen_size.x, 34)), stripe_color, true)

	for band in range(3):
		var band_top := fmod(band * 220.0 + scroll * 0.45, screen_size.y + 180.0) - 180.0
		draw_rect(Rect2(Vector2(0, band_top), Vector2(screen_size.x, 90.0)), band_color, true)

	if theme_id == "stage_2":
		for cloud in range(4):
			var cloud_top := fmod(cloud * 240.0 + scroll * 0.25, screen_size.y + 220.0) - 220.0
			draw_rect(Rect2(Vector2(0, cloud_top), Vector2(screen_size.x, 120.0)), Color(0.16, 0.2, 0.28, 0.08), true)
		if flash_alpha > 0.0:
			draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.84, 0.92, 1.0, flash_alpha), true)
			for bolt in range(2):
				var bolt_x := 90.0 + bolt * 280.0 + sin(scroll * 0.01 + bolt) * 18.0
				draw_line(Vector2(bolt_x, 0.0), Vector2(bolt_x + 18.0, screen_size.y * 0.48), Color(0.82, 0.92, 1.0, flash_alpha * 1.6), 3.0)
				draw_line(Vector2(bolt_x + 18.0, screen_size.y * 0.48), Vector2(bolt_x - 6.0, screen_size.y), Color(0.82, 0.92, 1.0, flash_alpha * 1.2), 2.0)

	for star in stars:
		draw_circle(star.position, star.size, star_color)
