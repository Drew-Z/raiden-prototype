extends RefCounted
class_name StageCatalog

const STAGE_ONE_SCRIPT := preload("res://scripts/game/stage_data_v2.gd")
const STAGE_TWO_SCRIPT := preload("res://scripts/game/stage_data_v3.gd")


static func get_stage_ids() -> Array[String]:
	return ["stage_1", "stage_2"]


static func get_stage_meta(stage_id: String) -> Dictionary:
	match stage_id:
		"stage_2":
			return {
				"id": "stage_2",
				"name": "STAGE 02 // STORM FRONT",
				"menu_label": "Stage 02",
				"tagline": "Dense side pressure and a heavier boss lane check.",
				"summary": "Second stage skeleton focused on tighter side threats, new screener enemies and a more aggressive boss setup."
			}
		_:
			return {
				"id": "stage_1",
				"name": "STAGE 01 // SCRAMBLE",
				"menu_label": "Stage 01",
				"tagline": "Baseline showcase route with clear pacing and a readable boss.",
				"summary": "Original showcase stage built around growth, bomb routing and a compact boss finish."
			}


static func get_stage_data_script(stage_id: String):
	match stage_id:
		"stage_2":
			return STAGE_TWO_SCRIPT
		_:
			return STAGE_ONE_SCRIPT
