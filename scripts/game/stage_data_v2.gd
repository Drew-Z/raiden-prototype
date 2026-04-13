extends RefCounted
class_name StageDataV2


static func build_waves(playfield_size: Vector2) -> Array[Dictionary]:
	return [
		{
			"time": 1.3,
			"formation": "line",
			"count": 4,
			"start_x": 100.0,
			"gap": 112.0,
			"velocity": Vector2(0, 176),
			"health": 20,
			"fire_interval": 2.6,
			"drop_chance": 0.24
		},
		{
			"time": 3.6,
			"formation": "line",
			"count": 5,
			"start_x": 78.0,
			"gap": 96.0,
			"velocity": Vector2(0, 195),
			"health": 24,
			"fire_interval": 2.0,
			"drop_chance": 0.3
		},
		{
			"time": 5.9,
			"formation": "angled_left",
			"count": 4,
			"start_x": -30.0,
			"start_y": -40.0,
			"gap": 68.0,
			"velocity": Vector2(125, 188),
			"health": 22,
			"fire_interval": 0.0,
			"drop_chance": 0.25
		},
		{
			"time": 6.8,
			"formation": "angled_right",
			"count": 4,
			"start_x": playfield_size.x + 30.0,
			"start_y": -55.0,
			"gap": 68.0,
			"velocity": Vector2(-125, 188),
			"health": 22,
			"fire_interval": 0.0,
			"drop_chance": 0.25
		},
		{
			"time": 9.2,
			"formation": "sniper_line",
			"count": 3,
			"start_x": 126.0,
			"gap": 144.0,
			"velocity": Vector2(0, 126),
			"health": 30,
			"fire_interval": 1.55,
			"drop_chance": 0.36
		},
		{
			"time": 10.8,
			"formation": "sine",
			"count": 5,
			"start_x": playfield_size.x * 0.5,
			"gap": 48.0,
			"velocity": Vector2(0, 148),
			"health": 28,
			"fire_interval": 1.85,
			"drop_chance": 0.34,
			"amplitude": 156.0,
			"frequency": 2.2
		},
		{
			"time": 13.1,
			"formation": "wall",
			"count": 4,
			"start_x": 118.0,
			"gap": 104.0,
			"velocity": Vector2(0, 132),
			"health": 34,
			"fire_interval": 1.35,
			"drop_chance": 0.36
		},
		{
			"time": 15.6,
			"formation": "dash_pair",
			"count": 4,
			"velocity": Vector2(88, 178),
			"acceleration": Vector2(38, 120),
			"health": 24,
			"fire_interval": 0.0,
			"drop_chance": 0.0
		},
		{
			"time": 18.5,
			"formation": "escort",
			"count": 6,
			"start_x": 0.0,
			"velocity": Vector2(0, 165),
			"health": 30,
			"fire_interval": 1.5,
			"drop_chance": 0.38
		},
		{
			"time": 20.2,
			"formation": "sniper_line",
			"count": 4,
			"start_x": 90.0,
			"gap": 120.0,
			"velocity": Vector2(0, 138),
			"health": 34,
			"fire_interval": 1.32,
			"drop_chance": 0.4
		},
		{
			"time": 21.3,
			"formation": "sine",
			"count": 6,
			"start_x": playfield_size.x * 0.5,
			"gap": 46.0,
			"velocity": Vector2(0, 164),
			"health": 32,
			"fire_interval": 1.35,
			"drop_chance": 0.42,
			"amplitude": 188.0,
			"frequency": 2.5
		},
		{
			"time": 23.0,
			"formation": "carrier",
			"position_x": playfield_size.x * 0.5,
			"velocity": Vector2(0, 124),
			"health": 68,
			"fire_interval": 1.12,
			"drop_chance": 1.0,
			"drop_kind": "bomb"
		},
		{
			"time": 24.0,
			"formation": "angled_left",
			"count": 5,
			"start_x": -32.0,
			"start_y": -46.0,
			"gap": 62.0,
			"velocity": Vector2(155, 210),
			"health": 26,
			"fire_interval": 0.0,
			"drop_chance": 0.0
		},
		{
			"time": 24.4,
			"formation": "angled_right",
			"count": 5,
			"start_x": playfield_size.x + 32.0,
			"start_y": -76.0,
			"gap": 62.0,
			"velocity": Vector2(-155, 210),
			"health": 26,
			"fire_interval": 0.0,
			"drop_chance": 0.0
		},
		{
			"time": 25.8,
			"formation": "dash_pair",
			"count": 6,
			"velocity": Vector2(96, 198),
			"acceleration": Vector2(48, 140),
			"health": 28,
			"fire_interval": 0.0,
			"drop_chance": 0.0
		},
		{
			"time": 26.6,
			"formation": "wall",
			"count": 5,
			"start_x": 70.0,
			"gap": 100.0,
			"velocity": Vector2(0, 154),
			"health": 38,
			"fire_interval": 1.15,
			"drop_chance": 0.42
		}
	]


static func build_events(playfield_size: Vector2) -> Array[Dictionary]:
	return [
		{"time": 0.6, "type": "banner", "text": "OPENING SWEEP", "duration": 1.4},
		{"time": 4.8, "type": "banner", "text": "KEEP FIRE ROUTE", "duration": 0.8},
		{"time": 9.3, "type": "banner", "text": "MID ASSAULT", "duration": 1.2},
		{"time": 14.8, "type": "pickup", "pickup_type": "power", "position": Vector2(playfield_size.x * 0.5, -28.0)},
		{"time": 14.8, "type": "banner", "text": "WEAPON CAPSULE", "duration": 0.9},
		{"time": 18.0, "type": "banner", "text": "FINAL PUSH", "duration": 1.2},
		{"time": 22.7, "type": "banner", "text": "ARMORED CARRIER", "duration": 0.9},
		{"time": 25.4, "type": "pickup", "pickup_type": "bomb", "position": Vector2(playfield_size.x * 0.5, -32.0)},
		{"time": 25.4, "type": "banner", "text": "BOMB SUPPLY INBOUND", "duration": 1.1},
		{"time": 28.1, "type": "banner", "text": "BOSS WARNING", "duration": 1.5}
	]


static func build_boss(playfield_size: Vector2) -> Dictionary:
	return {
		"time": 29.2,
		"position": Vector2(playfield_size.x * 0.5, -120.0),
		"pattern": "boss",
		"health": 640,
		"score_value": 3200,
		"fire_interval": 0.94,
		"fire_timer": 1.2,
		"amplitude": 162.0,
		"frequency": 1.0,
		"target_y": 174.0,
		"boss_anchor_x": playfield_size.x * 0.5,
		"is_boss": true,
		"boss_name": "HX-1 TEST CARRIER",
		"bullet_speed": 276.0,
		"drop_chance": 0.0,
		"tint": Color(0.88, 0.18, 0.18, 0.95)
	}
