extends Node2D

var lifetime := 0.32
var elapsed := 0.0
var effect_scale := 1.0
var effect_color := Color(1.0, 0.56, 0.34, 0.95)
var spark_rotation := 0.0


func configure(scale_value: float = 1.0, color_value: Color = Color(1.0, 0.56, 0.34, 0.95)):
	effect_scale = scale_value
	effect_color = color_value
	return self


func _process(delta: float) -> void:
	elapsed += delta
	spark_rotation += delta * 4.4
	if elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var ratio: float = clampf(elapsed / lifetime, 0.0, 1.0)
	var outer_radius: float = lerpf(8.0, 30.0 * effect_scale, ratio)
	var inner_radius: float = lerpf(4.0, 16.0 * effect_scale, ratio)
	var alpha: float = 1.0 - ratio
	draw_circle(Vector2.ZERO, outer_radius, Color(effect_color.r, effect_color.g, effect_color.b, 0.22 * alpha))
	draw_circle(Vector2.ZERO, outer_radius * 1.34, Color(0.28, 0.18, 0.12, 0.12 * alpha))
	draw_circle(Vector2.ZERO, inner_radius, Color(1.0, 0.92, 0.7, 0.62 * alpha))
	draw_arc(Vector2.ZERO, outer_radius * 0.72, 0.0, TAU, 24, Color(1.0, 0.84, 0.58, 0.48 * alpha), 2.0)
	for angle_step in range(8):
		var angle: float = TAU * float(angle_step) / 8.0 + spark_rotation * 0.22
		var point := Vector2.RIGHT.rotated(angle) * outer_radius
		draw_line(Vector2.ZERO, point, Color(effect_color.r, effect_color.g, effect_color.b, 0.76 * alpha), 1.8)
	for shard_index in range(6):
		var shard_angle := TAU * float(shard_index) / 6.0 + ratio * 1.2
		var shard_start := Vector2.RIGHT.rotated(shard_angle) * inner_radius * 0.8
		var shard_end := Vector2.RIGHT.rotated(shard_angle) * outer_radius * 1.28
		draw_line(shard_start, shard_end, Color(1.0, 0.9, 0.68, 0.76 * alpha), 1.6)
