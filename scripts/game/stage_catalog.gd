extends RefCounted
class_name StageCatalog

const STAGE_ONE_SCRIPT := preload("res://scripts/game/stage_data_v2.gd")
const STAGE_TWO_SCRIPT := preload("res://scripts/game/stage_data_v3.gd")


static func get_stage_ids() -> Array[String]:
	return ["stage_1", "stage_2"]


static func get_stage_order() -> Array[String]:
	return get_stage_ids()


static func get_stage_index(stage_id: String) -> int:
	return get_stage_order().find(stage_id)


static func get_next_stage_id(stage_id: String) -> String:
	var stage_order := get_stage_order()
	var current_index := stage_order.find(stage_id)
	if current_index == -1 or current_index >= stage_order.size() - 1:
		return ""
	return stage_order[current_index + 1]


static func get_stage_meta(stage_id: String) -> Dictionary:
	match stage_id:
		"stage_2":
			return {
				"id": "stage_2",
				"name": "STAGE 02 // STORM FRONT",
				"name_zh": "第二关 // 风暴前线",
				"menu_label": "Stage 02",
				"menu_label_zh": "第二关",
				"tagline": "Dense side pressure, carried growth and a heavier storm boss.",
				"tagline_zh": "更强的侧压、继承成长，以及更有压迫感的风暴 Boss。",
				"summary": "Expanded second-stage route built around side pressure, screen-fire control and a more aggressive storm boss.",
				"summary_zh": "扩展后的第二关路线，围绕侧向压迫、屏障火力处理和更激进的风暴 Boss 展开。",
				"standalone_start_state": {
					"lives": 3,
					"bombs": 4,
					"fire_level": 3
				}
			}
		_:
			return {
				"id": "stage_1",
				"name": "STAGE 01 // SCRAMBLE",
				"name_zh": "第一关 // 突入空域",
				"menu_label": "Stage 01",
				"menu_label_zh": "第一关",
				"tagline": "Showcase opener with clean growth, bomb routing and chapter handoff.",
				"tagline_zh": "以清晰成长、炸弹路线和章节交接为核心的展示开场。",
				"summary": "Primary showcase route built around readable pacing, growth and a compact boss finish.",
				"summary_zh": "作为主展示样片的开场路线，强调可读节奏、成长体验和紧凑的 Boss 收束。"
			}


static func get_stage_data_script(stage_id: String):
	match stage_id:
		"stage_2":
			return STAGE_TWO_SCRIPT
		_:
			return STAGE_ONE_SCRIPT
