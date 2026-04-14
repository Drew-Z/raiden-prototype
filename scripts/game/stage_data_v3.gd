extends RefCounted
class_name StageDataV3


static func build_waves(playfield_size: Vector2) -> Array[Dictionary]:
	return [
		{
			"time": 1.2,
			"formation": "line",
			"count": 5,
			"start_x": 78.0,
			"gap": 96.0,
			"velocity": Vector2(0, 188),
			"health": 22,
			"fire_interval": 2.2,
			"drop_chance": 0.24
		},
		{
			"time": 3.4,
			"formation": "dash_pair",
			"count": 4,
			"velocity": Vector2(92, 184),
			"acceleration": Vector2(46, 126),
			"health": 24,
			"fire_interval": 0.0,
			"drop_chance": 0.0
		},
		{
			"time": 5.1,
			"formation": "screener_line",
			"count": 3,
			"start_x": 116.0,
			"gap": 154.0,
			"velocity": Vector2(0, 132),
			"health": 34,
			"fire_interval": 1.25,
			"drop_chance": 0.28
		},
		{
			"time": 7.4,
			"formation": "angled_left",
			"count": 4,
			"start_x": -34.0,
			"start_y": -40.0,
			"gap": 64.0,
			"velocity": Vector2(146, 198),
			"health": 24,
			"fire_interval": 0.0,
			"drop_chance": 0.18
		},
		{
			"time": 7.8,
			"formation": "angled_right",
			"count": 4,
			"start_x": playfield_size.x + 34.0,
			"start_y": -72.0,
			"gap": 64.0,
			"velocity": Vector2(-146, 198),
			"health": 24,
			"fire_interval": 0.0,
			"drop_chance": 0.18
		},
		{
			"time": 8.9,
			"formation": "carrier",
			"position_x": playfield_size.x * 0.5,
			"velocity": Vector2(0, 118),
			"health": 64,
			"fire_interval": 1.18,
			"drop_chance": 1.0,
			"drop_kind": "power"
		},
		{
			"time": 9.8,
			"formation": "anchor_column",
			"count": 2,
			"start_x": 144.0,
			"gap": 252.0,
			"velocity_y": 186.0,
			"hold_y": 182.0,
			"hold_duration": 2.1,
			"hover_amplitude": 18.0,
			"frequency": 1.5,
			"release_speed": 180.0,
			"health": 46,
			"fire_interval": 1.0,
			"drop_chance": 0.34
		},
		{
			"time": 11.5,
			"formation": "pincer_line",
			"count": 4,
			"start_x": 92.0,
			"gap": 118.0,
			"velocity": Vector2(0, 144),
			"health": 32,
			"fire_interval": 1.08,
			"drop_chance": 0.32
		},
		{
			"time": 12.6,
			"formation": "suppressor_line",
			"count": 3,
			"start_x": 106.0,
			"gap": 164.0,
			"velocity": Vector2(0, 140),
			"health": 34,
			"fire_interval": 1.12,
			"drop_chance": 0.28
		},
		{
			"time": 13.8,
			"formation": "carrier",
			"position_x": playfield_size.x * 0.5,
			"velocity": Vector2(0, 122),
			"health": 74,
			"fire_interval": 1.02,
			"drop_chance": 1.0,
			"drop_kind": "power"
		},
		{
			"time": 15.3,
			"formation": "escort",
			"count": 6,
			"start_x": 0.0,
			"velocity": Vector2(0, 172),
			"health": 32,
			"fire_interval": 1.34,
			"drop_chance": 0.34
		},
		{
			"time": 17.0,
			"formation": "screener_line",
			"count": 4,
			"start_x": 86.0,
			"gap": 122.0,
			"velocity": Vector2(0, 146),
			"health": 38,
			"fire_interval": 1.0,
			"drop_chance": 0.36
		},
		{
			"time": 19.2,
			"formation": "sine",
			"count": 6,
			"start_x": playfield_size.x * 0.5,
			"gap": 44.0,
			"velocity": Vector2(0, 168),
			"health": 32,
			"fire_interval": 1.28,
			"drop_chance": 0.4,
			"amplitude": 178.0,
			"frequency": 2.6
		},
		{
			"time": 21.0,
			"formation": "dash_pair",
			"count": 6,
			"velocity": Vector2(98, 204),
			"acceleration": Vector2(54, 150),
			"health": 30,
			"fire_interval": 0.0,
			"drop_chance": 0.0
		},
		{
			"time": 22.2,
			"formation": "pincer_line",
			"count": 4,
			"start_x": 88.0,
			"gap": 122.0,
			"velocity": Vector2(0, 152),
			"health": 34,
			"fire_interval": 0.98,
			"drop_chance": 0.34
		},
		{
			"time": 22.9,
			"formation": "sniper_line",
			"count": 3,
			"start_x": 110.0,
			"gap": 160.0,
			"velocity": Vector2(0, 142),
			"health": 34,
			"fire_interval": 1.02,
			"drop_chance": 0.26
		},
		{
			"time": 23.6,
			"formation": "carrier",
			"position_x": playfield_size.x * 0.5,
			"velocity": Vector2(0, 126),
			"health": 78,
			"fire_interval": 1.0,
			"drop_chance": 1.0,
			"drop_kind": "bomb"
		},
		{
			"time": 24.8,
			"formation": "anchor_column",
			"count": 3,
			"start_x": 110.0,
			"gap": 160.0,
			"velocity_y": 198.0,
			"hold_y": 200.0,
			"hold_duration": 1.8,
			"hover_amplitude": 18.0,
			"frequency": 1.9,
			"release_speed": 188.0,
			"health": 50,
			"fire_interval": 0.92,
			"drop_chance": 0.34
		},
		{
			"time": 25.6,
			"formation": "suppressor_line",
			"count": 4,
			"start_x": 82.0,
			"gap": 126.0,
			"velocity": Vector2(0, 154),
			"health": 38,
			"fire_interval": 0.96,
			"drop_chance": 0.26
		},
		{
			"time": 26.2,
			"formation": "wall",
			"count": 5,
			"start_x": 70.0,
			"gap": 100.0,
			"velocity": Vector2(0, 158),
			"health": 40,
			"fire_interval": 1.08,
			"drop_chance": 0.38
		}
	]


static func build_events(playfield_size: Vector2) -> Array[Dictionary]:
	return [
		{"time": 0.6, "type": "banner", "text": "STORM FRONT", "duration": 1.2, "detail": "Stage 02 leans harder on side pressure and carried resources. Keep the route moving.", "card_duration": 1.45},
		{"time": 3.2, "type": "banner", "text": "SIDE DASH", "duration": 0.8, "detail": "Fast side entries are opening the route. Read the edges before the board closes.", "card_duration": 1.35},
		{"time": 5.0, "type": "banner", "text": "SCREEN FIRE", "duration": 0.9, "detail": "Screener units are dropping slow lane bullets. Route around the gaps, not through them.", "card_duration": 1.5, "card_color": Color(0.78, 0.92, 1.0)},
		{"time": 8.9, "type": "banner", "text": "FORWARD SUPPLY", "duration": 0.95, "detail": "Break the center carrier to stabilize growth before the route locks down.", "card_duration": 1.45, "card_color": Color(0.66, 0.94, 1.0)},
		{"time": 9.6, "type": "banner", "text": "ANCHOR LINE", "duration": 0.9, "detail": "Anchors are pinning the route. Shift early and preserve a center exit.", "card_duration": 1.45},
		{"time": 12.5, "type": "banner", "text": "SUPPRESSION FAN", "duration": 0.85, "detail": "Suppressor units spread a wide fan across the board. Pre-position before the cone closes.", "card_duration": 1.45, "card_color": Color(1.0, 0.78, 0.42)},
		{"time": 13.8, "type": "pickup", "pickup_type": "power", "position": Vector2(playfield_size.x * 0.5, -26.0)},
		{"time": 13.8, "type": "banner", "text": "WEAPON SUPPLY", "duration": 0.9, "detail": "Lock this power route before the mid-board pressure spikes.", "card_duration": 1.4, "card_color": Color(0.62, 0.94, 1.0)},
		{
			"time": 16.1,
			"type": "storm_cross",
			"lanes": [108.0, 432.0],
			"rows": [438.0],
			"telegraph": 1.0,
			"active": 0.34,
			"banner": "STORM CROSS",
			"title": "STORM CROSS",
			"detail": "Vertical strikes and a lateral sweep are collapsing together. Commit to the center gap before the cross locks in.",
			"card_duration": 1.45,
			"support_delay": 0.24,
			"support_wave": {
				"formation": "suppressor_line",
				"count": 2,
				"start_x": 144.0,
				"gap": 252.0,
				"velocity": Vector2(0, 144),
				"health": 34,
				"fire_interval": 1.02,
				"drop_chance": 0.0
			}
		},
		{"time": 16.8, "type": "banner", "text": "SCREEN WALL", "duration": 0.9, "detail": "Second screener block inbound. Control space before the escorts stack on top.", "card_duration": 1.45, "card_color": Color(0.78, 0.92, 1.0)},
		{"time": 20.8, "type": "banner", "text": "FINAL PRESSURE", "duration": 1.1, "detail": "Dashers and pincer fire will overlap here. Bomb routing is safer than late recovery.", "card_duration": 1.6, "card_color": Color(1.0, 0.78, 0.44)},
		{"time": 22.8, "type": "banner", "text": "SNIPER CROSS", "duration": 0.85, "detail": "Late snipers are layering on top of the pincer lane. Clear one side before re-centering.", "card_duration": 1.45, "card_color": Color(1.0, 0.84, 0.52)},
		{"time": 23.6, "type": "pickup", "pickup_type": "bomb", "position": Vector2(playfield_size.x * 0.5, -30.0)},
		{"time": 23.6, "type": "banner", "text": "BOMB REFIT", "duration": 1.0, "detail": "Final bomb stock before boss entry. Cash it into a phase skip if the lane collapses.", "card_duration": 1.55, "card_color": Color(1.0, 0.72, 0.38)},
		{"time": 25.6, "type": "banner", "text": "SUPPRESSION FAN", "duration": 0.85, "detail": "Late suppressors are pinning the board before the wall drop. Choose one side and break through.", "card_duration": 1.45, "card_color": Color(1.0, 0.78, 0.42)},
		{
			"time": 27.0,
			"type": "storm_cross",
			"lanes": [124.0, 416.0],
			"rows": [332.0, 604.0],
			"telegraph": 0.96,
			"active": 0.34,
			"banner": "FINAL STORM",
			"title": "STORM CROSS",
			"detail": "Final crossfire before boss entry. Slide through one clean lane and save the rest of the board for the boss reset.",
			"card_duration": 1.5,
			"support_delay": 0.18,
			"support_wave": {
				"formation": "sniper_line",
				"count": 2,
				"start_x": 150.0,
				"gap": 240.0,
				"velocity": Vector2(0, 150),
				"health": 34,
				"fire_interval": 0.96,
				"drop_chance": 0.0
			}
		},
		{"time": 28.0, "type": "banner", "text": "BOSS WARNING", "duration": 1.5}
	]


static func build_boss(playfield_size: Vector2) -> Dictionary:
	return {
		"time": 29.0,
		"position": Vector2(playfield_size.x * 0.5, -120.0),
		"pattern": "boss",
		"health": 760,
		"score_value": 4200,
		"fire_interval": 0.88,
		"fire_timer": 1.08,
		"amplitude": 174.0,
		"frequency": 1.08,
		"target_y": 170.0,
		"boss_anchor_x": playfield_size.x * 0.5,
		"is_boss": true,
		"boss_name": "VX-2 STORM GUNSHIP",
		"boss_style": "storm",
		"boss_intro_banner": "WARNING // VX-2 LOCK",
		"boss_intro_title": "TARGET // VX-2 STORM GUNSHIP",
		"boss_intro_detail": "Storm batteries flood the side lanes. Carry one bomb into overdrive or burst through the core window.",
		"core_phase_detail": "Outer batteries are resetting. Cut back through center and burn the exposed storm core.",
		"final_core_phase_detail": "The final storm core is open. Push hard now before the sweep lines accelerate.",
		"final_warning_detail": "The route is about to collapse into overdrive. This is the last clean bomb window before the storm locks both sides.",
		"overdrive_detail": "Overdrive is closing the side lanes. Preserve a clean edge, then bomb through the next collapse.",
		"finish_window_detail": "The storm core is flickering under overload. Break through now while one breach line is still open.",
		"phase_2_hazard": {
			"type": "storm_strike",
			"lanes": [118.0, 422.0],
			"telegraph": 0.88,
			"active": 0.32,
			"banner": "PHASE SHIFT STORM",
			"title": "STORM RELOCK",
			"detail": "Phase shift is relocking the side lanes. Use the core window without giving up the center path.",
			"card_duration": 1.15
		},
		"phase_3_hazard": {
			"type": "storm_cross",
			"lanes": [132.0, 408.0],
			"rows": [444.0],
			"telegraph": 0.86,
			"active": 0.32,
			"banner": "FINAL CORE STORM",
			"title": "CORE WINDOW // STORM CROSS",
			"detail": "The final core is open, but the storm is still locking one cross-lane. Slide once, then commit hard.",
			"card_duration": 1.25
		},
		"overdrive_hazard": {
			"type": "storm_cross",
			"lanes": [148.0, 392.0],
			"rows": [318.0, 612.0],
			"telegraph": 0.82,
			"active": 0.32,
			"banner": "OVERDRIVE STORM",
			"title": "OVERDRIVE // STORM CROSS",
			"detail": "Overdrive is re-flooding the board. Hold one clean edge and cut back in after the cross collapses.",
			"card_duration": 1.35,
			"support_delay": 0.16,
			"support_wave": {
				"formation": "suppressor_line",
				"count": 2,
				"start_x": 154.0,
				"gap": 232.0,
				"velocity": Vector2(0, 150),
				"health": 34,
				"fire_interval": 0.92,
				"drop_chance": 0.0
			}
		},
		"finish_window_hazard": {
			"type": "storm_strike",
			"lanes": [118.0, 426.0],
			"telegraph": 0.72,
			"active": 0.26,
			"banner": "FINAL BREACH",
			"title": "FINISH WINDOW // BREACH LINE",
			"detail": "The side lanes are collapsing one last time. Center is your final clean cut through the storm core.",
			"card_duration": 1.1
		},
		"bullet_speed": 294.0,
		"drop_chance": 0.0,
		"tint": Color(0.84, 0.2, 0.18, 0.95),
		"overdrive_threshold": 0.22
	}
