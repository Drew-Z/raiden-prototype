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
			"drop_chance": 0.12
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
			"drop_chance": 0.16
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
			"drop_chance": 0.12
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
			"drop_chance": 0.12
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
			"drop_chance": 0.18
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
			"drop_chance": 0.16,
			"amplitude": 156.0,
			"frequency": 2.2
		},
		{
			"time": 12.0,
			"formation": "anchor_column",
			"count": 2,
			"start_x": 160.0,
			"gap": 220.0,
			"velocity_y": 184.0,
			"hold_y": 188.0,
			"hold_duration": 2.0,
			"hover_amplitude": 14.0,
			"frequency": 1.5,
			"release_speed": 176.0,
			"health": 44,
			"fire_interval": 1.1,
			"drop_chance": 0.16
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
			"drop_chance": 0.18
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
			"time": 17.2,
			"formation": "pincer_line",
			"count": 3,
			"start_x": 110.0,
			"gap": 160.0,
			"velocity": Vector2(0, 142),
			"health": 30,
			"fire_interval": 1.2,
			"drop_chance": 0.16
		},
		{
			"time": 18.5,
			"formation": "escort",
			"count": 6,
			"start_x": 0.0,
			"velocity": Vector2(0, 165),
			"health": 30,
			"fire_interval": 1.5,
			"drop_chance": 0.18
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
			"drop_chance": 0.2
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
			"drop_chance": 0.22,
			"amplitude": 188.0,
			"frequency": 2.5
		},
		{
			"time": 22.0,
			"formation": "anchor_column",
			"count": 3,
			"start_x": 110.0,
			"gap": 160.0,
			"velocity_y": 196.0,
			"hold_y": 206.0,
			"hold_duration": 1.9,
			"hover_amplitude": 20.0,
			"frequency": 1.8,
			"release_speed": 188.0,
			"health": 48,
			"fire_interval": 0.96,
			"drop_chance": 0.18
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
			"time": 26.0,
			"formation": "pincer_line",
			"count": 4,
			"start_x": 88.0,
			"gap": 122.0,
			"velocity": Vector2(0, 154),
			"health": 34,
			"fire_interval": 1.0,
			"drop_chance": 0.16
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
			"drop_chance": 0.18
		}
	]


static func build_events(playfield_size: Vector2) -> Array[Dictionary]:
	return [
		{"time": 0.6, "type": "banner", "text": "OPENING SWEEP", "zh_text": "开场扫场", "duration": 1.4},
		{"time": 4.8, "type": "banner", "text": "KEEP FIRE ROUTE", "zh_text": "保持火力路线", "duration": 0.8},
		{"time": 9.3, "type": "banner", "text": "MID ASSAULT", "zh_text": "中段突击", "duration": 1.2, "detail": "Snipers are online. Clear lanes early before the field slows down.", "zh_detail": "狙击编队已经上线，在场面变慢之前尽快清掉关键通道。", "card_duration": 1.55},
		{"time": 11.7, "type": "banner", "text": "ANCHOR SCREEN", "zh_text": "锚点封线", "duration": 0.9, "detail": "Anchor units hold space and seal lanes. Shift early, not late.", "zh_detail": "锚点敌机会占住空间并封锁路线，必须提前转位，不能等到最后。", "card_duration": 1.45},
		{"time": 14.8, "type": "pickup", "pickup_type": "power", "position": Vector2(playfield_size.x * 0.5, -28.0)},
		{"time": 14.8, "type": "banner", "text": "WEAPON CAPSULE", "zh_text": "武器补给舱", "duration": 0.9, "detail": "Secure the power drop and push toward Lv4 before the final block.", "zh_detail": "拿下这枚火力补给，在终盘压迫前尽量把火力抬到 Lv4。", "card_duration": 1.45, "card_color": Color(0.62, 0.94, 1.0)},
		{"time": 17.0, "type": "banner", "text": "PINCER LOCK", "zh_text": "夹击封锁", "duration": 0.8, "detail": "Crossfire units are closing the lane. Commit to a full side-step.", "zh_detail": "交叉火力正在封路，这里必须果断完成一次整段横移。", "card_duration": 1.35, "card_color": Color(1.0, 0.74, 0.42)},
		{"time": 18.0, "type": "banner", "text": "FINAL PUSH", "zh_text": "终盘推进", "duration": 1.2},
		{"time": 21.9, "type": "banner", "text": "ANCHOR SCREEN", "zh_text": "锚点封线", "duration": 0.9, "detail": "The board is tightening. Hold bomb stock if the route collapses.", "zh_detail": "场面正在收紧，如果路线开始崩塌，记得把炸弹库存留住。", "card_duration": 1.45},
		{"time": 22.7, "type": "banner", "text": "ARMORED CARRIER", "zh_text": "装甲运输机", "duration": 0.9, "detail": "Carrier inbound. Break it for the supply route before boss setup.", "zh_detail": "运输机即将入场，在 Boss 预备段之前击毁它以打开补给路线。", "card_duration": 1.5, "card_color": Color(1.0, 0.82, 0.48)},
		{"time": 25.4, "type": "pickup", "pickup_type": "bomb", "position": Vector2(playfield_size.x * 0.5, -32.0)},
		{"time": 25.4, "type": "banner", "text": "BOMB SUPPLY INBOUND", "zh_text": "炸弹补给到达", "duration": 1.1, "detail": "One last bomb stock before the boss. Convert it into a safe phase skip.", "zh_detail": "这是 Boss 前最后一枚炸弹补给，最好把它换成一次安全的转段跳过。", "card_duration": 1.6, "card_color": Color(1.0, 0.7, 0.36)},
		{"time": 25.9, "type": "banner", "text": "PINCER LOCK", "zh_text": "夹击封锁", "duration": 0.8, "detail": "Late crossfire ahead. Do not get trapped under the wall sweep.", "zh_detail": "后段交叉火力马上接上，不要被压在墙式扫场下面。", "card_duration": 1.35, "card_color": Color(1.0, 0.74, 0.42)},
		{"time": 28.1, "type": "banner", "text": "BOSS WARNING", "zh_text": "Boss 警报", "duration": 1.5}
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
		"zh_boss_name": "HX-1 试作运载舰",
		"boss_style": "carrier",
		"boss_intro_banner": "WARNING // HX-1 DESCENT",
		"zh_boss_intro_banner": "警报 // HX-1 下降",
		"boss_intro_title": "TARGET // HX-1 TEST CARRIER",
		"zh_boss_intro_title": "目标 // HX-1 试作运载舰",
		"boss_intro_detail": "Phase shifts expose the core. Hold one bomb for the late pressure window.",
		"zh_boss_intro_detail": "相位切换会暴露核心，尽量把一个炸弹留给后段高压窗口。",
		"core_phase_detail": "The side guns are resetting. Step back in and burn the open core.",
		"zh_core_phase_detail": "两侧炮台正在重置，重新切回中线并灼烧开放的核心。",
		"final_core_phase_detail": "Final phase has opened the core. Push damage now before overdrive speed ramps up.",
		"zh_final_core_phase_detail": "最终阶段已经打开核心，必须在过载提速前把伤害压进去。",
		"overdrive_detail": "Boss speed is up. Preserve spacing first, then cash bomb or core burst windows.",
		"zh_overdrive_detail": "Boss 已经提速，先保住站位，再去兑现炸弹或核心爆发窗口。",
		"bullet_speed": 276.0,
		"drop_chance": 0.0,
		"tint": Color(0.88, 0.18, 0.18, 0.95)
	}
