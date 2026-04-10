extends Node2D
class_name Starfield

var scroll := 0.0
var speed := 140.0
var screen_size := Vector2(540, 960)
var stars: Array[Dictionary] = []


func _ready() -> void:
	for _index in range(24):
		stars.append({
			"position": Vector2(randf() * screen_size.x, randf() * screen_size.y),
			"size": randf_range(1.0, 3.0),
			"speed": randf_range(0.55, 1.45)
		})


func _process(delta: float) -> void:
	scroll = fmod(scroll + speed * delta, 80.0)
	for star in stars:
		var next_position: Vector2 = star.position
		next_position.y += speed * star.speed * delta
		if next_position.y > screen_size.y:
			next_position.y = -8.0
			next_position.x = randf() * screen_size.x
		star.position = next_position
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.03, 0.05, 0.11), true)

	for lane in range(4):
		var x := 40.0 + lane * ((screen_size.x - 80.0) / 3.0)
		draw_line(Vector2(x, 0), Vector2(x, screen_size.y), Color(0.1, 0.16, 0.25, 0.55), 2.0)

	var stripe_color := Color(0.07, 0.2, 0.29, 0.42)
	for stripe in range(14):
		var top := fmod(stripe * 80.0 + scroll, screen_size.y + 80.0) - 80.0
		draw_rect(Rect2(Vector2(0, top), Vector2(screen_size.x, 34)), stripe_color, true)

	for star in stars:
		draw_circle(star.position, star.size, Color(0.86, 0.95, 1.0, 0.88))
