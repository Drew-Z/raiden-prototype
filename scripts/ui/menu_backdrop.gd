extends Control

var time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.018, 0.024, 0.052), true)

	var top_height := minf(size.y, 300.0)
	draw_rect(Rect2(Vector2(0.0, 80.0), Vector2(size.x, top_height * 0.68)), Color(0.06, 0.13, 0.24, 0.84), true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y)), Color(0.02, 0.028, 0.06, 0.34), true)

	var center_x := size.x * 0.5
	var scroll := fmod(time * 48.0, 72.0)
	for index in range(18):
		var y := fmod(float(index) * 72.0 + scroll, size.y + 72.0) - 72.0
		var alpha := 0.08 + 0.08 * sin(time * 0.8 + float(index))
		draw_line(Vector2(0.0, y), Vector2(size.x, y), Color(0.22, 0.42, 0.62, alpha), 1.0)

	for lane in range(5):
		var lane_ratio := float(lane) / 4.0
		var x := lerpf(36.0, size.x - 36.0, lane_ratio)
		draw_line(Vector2(x, 0.0), Vector2(x + (x - center_x) * 0.08, size.y), Color(0.18, 0.36, 0.58, 0.16), 1.0)

	for star in range(36):
		var seed := float(star)
		var x := fmod(seed * 73.17 + sin(seed) * 41.0, maxf(size.x, 1.0))
		var y := fmod(seed * 119.7 + time * (18.0 + fmod(seed, 4.0) * 10.0), maxf(size.y, 1.0))
		var radius := 1.0 + fmod(seed, 3.0) * 0.45
		draw_circle(Vector2(x, y), radius, Color(0.72, 0.88, 1.0, 0.16 + 0.08 * sin(time * 2.0 + seed)))

	var radar_center := Vector2(center_x, 214.0)
	var radar_radius := minf(size.x * 0.38, 230.0)
	draw_arc(radar_center, radar_radius, PI * 1.05, PI * 1.95, 48, Color(0.48, 0.82, 1.0, 0.12), 2.0)
	draw_arc(radar_center, radar_radius * 0.68, PI * 1.08, PI * 1.92, 48, Color(0.48, 0.82, 1.0, 0.1), 1.5)
	var sweep_angle := PI * 1.05 + fmod(time * 0.55, PI * 0.9)
	var sweep_end := radar_center + Vector2(cos(sweep_angle), sin(sweep_angle)) * radar_radius
	draw_line(radar_center, sweep_end, Color(0.78, 0.94, 1.0, 0.2), 2.0)

	var runway_top := size.y * 0.48
	var runway_bottom := size.y
	draw_colored_polygon(PackedVector2Array([
		Vector2(center_x - 72.0, runway_top),
		Vector2(center_x + 72.0, runway_top),
		Vector2(size.x * 0.88, runway_bottom),
		Vector2(size.x * 0.12, runway_bottom)
	]), Color(0.04, 0.05, 0.08, 0.42))
	for mark in range(8):
		var y_mark := fmod(runway_top + float(mark) * 80.0 + scroll * 0.85, size.y + 80.0)
		var half_width := lerpf(10.0, 42.0, clampf((y_mark - runway_top) / maxf(size.y - runway_top, 1.0), 0.0, 1.0))
		draw_rect(Rect2(Vector2(center_x - half_width * 0.18, y_mark), Vector2(half_width * 0.36, 18.0)), Color(1.0, 0.84, 0.42, 0.18), true)
