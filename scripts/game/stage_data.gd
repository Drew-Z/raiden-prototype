extends RefCounted
class_name StageData


static func build_waves(playfield_size: Vector2) -> Array[Dictionary]:
	return [
		{
			"time": 1.4,
			"formation": "line",
			"count": 5,
			"start_x": 86.0,
			"gap": 92.0,
			"velocity": Vector2(0, 190),
			"health": 24,
			"fire_interval": 2.2,
			"drop_chance": 0.28
		},
		{
			"time": 4.8,
			"formation": "angled_left",
			"count": 4,
			"start_x": -30.0,
			"start_y": -40.0,
			"gap": 68.0,
			"velocity": Vector2(115, 175),
			"health": 22,
			"fire_interval": 0.0,
			"drop_chance": 0.25
		},
		{
			"time": 7.5,
			"formation": "angled_right",
			"count": 4,
			"start_x": playfield_size.x + 30.0,
			"start_y": -55.0,
			"gap": 68.0,
			"velocity": Vector2(-115, 175),
			"health": 22,
			"fire_interval": 0.0,
			"drop_chance": 0.25
		},
		{
			"time": 10.6,
			"formation": "sine",
			"count": 6,
			"start_x": playfield_size.x * 0.5,
			"gap": 48.0,
			"velocity": Vector2(0, 150),
			"health": 28,
			"fire_interval": 1.9,
			"drop_chance": 0.34,
			"amplitude": 170.0,
			"frequency": 2.2
		},
		{
			"time": 14.2,
			"formation": "wall",
			"count": 5,
			"start_x": 70.0,
			"gap": 100.0,
			"velocity": Vector2(0, 138),
			"health": 34,
			"fire_interval": 1.45,
			"drop_chance": 0.36
		},
		{
			"time": 18.0,
			"formation": "escort",
			"count": 6,
			"start_x": 0.0,
			"velocity": Vector2(0, 165),
			"health": 30,
			"fire_interval": 1.65,
			"drop_chance": 0.38
		}
	]


static func build_boss(playfield_size: Vector2) -> Dictionary:
	return {
		"time": 22.5,
		"position": Vector2(playfield_size.x * 0.5, -120.0),
		"pattern": "boss",
		"health": 420,
		"score_value": 2400,
		"fire_interval": 0.9,
		"amplitude": 148.0,
		"frequency": 1.15,
		"target_y": 180.0,
		"boss_anchor_x": playfield_size.x * 0.5,
		"is_boss": true,
		"boss_name": "HX-1 试验舰",
		"bullet_speed": 250.0,
		"drop_chance": 0.0,
		"tint": Color(0.88, 0.18, 0.18, 0.95)
	}
