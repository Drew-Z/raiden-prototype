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
				"menu_label": "Stage 02",
				"tagline": "Dense side pressure, carried growth and a heavier storm boss.",
				"summary": "Expanded second-stage route built around side pressure, screen-fire control and a more aggressive storm boss."
			}
		_:
			return {
				"id": "stage_1",
				"name": "STAGE 01 // SCRAMBLE",
				"menu_label": "Stage 01",
				"tagline": "Showcase opener with clean growth, bomb routing and chapter handoff.",
				"summary": "Primary showcase route built around readable pacing, growth and a compact boss finish."
			}


static func get_stage_data_script(stage_id: String):
	match stage_id:
		"stage_2":
			return STAGE_TWO_SCRIPT
		_:
			return STAGE_ONE_SCRIPT
