extends Node

const BUS_CONFIGS := [
	{"name": "BGM", "volume_db": -8.0},
	{"name": "SFX_Player", "volume_db": -4.5},
	{"name": "SFX_Enemy", "volume_db": -2.8},
	{"name": "SFX_Boss", "volume_db": -1.5},
	{"name": "SFX_UI", "volume_db": -4.0}
]
const BUS_COMPRESSORS := {
	"SFX_Player": {
		"tag": "codex_player_glue",
		"threshold": -18.0,
		"ratio": 3.2,
		"gain": -1.2,
		"attack_us": 8000.0,
		"release_ms": 90.0
	},
	"SFX_Enemy": {
		"tag": "codex_enemy_glue",
		"threshold": -16.5,
		"ratio": 3.8,
		"gain": -0.8,
		"attack_us": 7000.0,
		"release_ms": 110.0
	},
	"SFX_Boss": {
		"tag": "codex_boss_glue",
		"threshold": -15.0,
		"ratio": 4.4,
		"gain": -1.4,
		"attack_us": 6000.0,
		"release_ms": 140.0
	},
	"SFX_UI": {
		"tag": "codex_ui_glue",
		"threshold": -19.0,
		"ratio": 2.6,
		"gain": -0.6,
		"attack_us": 9000.0,
		"release_ms": 80.0
	}
}
const MIN_LINEAR := 0.001


func _ready() -> void:
	refresh_mix()


static func ensure_layout() -> void:
	for bus_config in BUS_CONFIGS:
		var bus_name: String = String(bus_config.get("name", ""))
		if bus_name.is_empty():
			continue
		var bus_index: int = AudioServer.get_bus_index(bus_name)
		if bus_index == -1:
			AudioServer.add_bus(AudioServer.bus_count)
			bus_index = AudioServer.bus_count - 1
			AudioServer.set_bus_name(bus_index, bus_name)
		AudioServer.set_bus_send(bus_index, "Master")
		_ensure_bus_processing(bus_name, bus_index)


static func _ensure_bus_processing(bus_name: String, bus_index: int) -> void:
	if not BUS_COMPRESSORS.has(bus_name):
		return
	var config: Dictionary = BUS_COMPRESSORS[bus_name]
	var effect := _find_compressor(bus_index, String(config.get("tag", "")))
	if effect == null:
		effect = AudioEffectCompressor.new()
		effect.resource_name = String(config.get("tag", bus_name))
		AudioServer.add_bus_effect(bus_index, effect, 0)
	_apply_compressor_config(effect, config)


static func _find_compressor(bus_index: int, tag: String) -> AudioEffectCompressor:
	for effect_index in range(AudioServer.get_bus_effect_count(bus_index)):
		var effect := AudioServer.get_bus_effect(bus_index, effect_index)
		if effect is AudioEffectCompressor:
			var compressor := effect as AudioEffectCompressor
			if tag.is_empty() or compressor.resource_name == tag:
				return compressor
	return null


static func _apply_compressor_config(effect: AudioEffectCompressor, config: Dictionary) -> void:
	effect.threshold = float(config.get("threshold", -18.0))
	effect.ratio = float(config.get("ratio", 3.0))
	effect.gain = float(config.get("gain", 0.0))
	effect.attack_us = float(config.get("attack_us", 8000.0))
	effect.release_ms = float(config.get("release_ms", 120.0))


func refresh_mix() -> void:
	ensure_layout()
	var bgm_linear := 0.85
	var sfx_linear := 0.9
	var run_state := get_node_or_null("/root/RunState")
	if is_instance_valid(run_state):
		bgm_linear = float(run_state.get_bgm_volume())
		sfx_linear = float(run_state.get_sfx_volume())

	for bus_config in BUS_CONFIGS:
		var bus_name: String = String(bus_config.get("name", ""))
		var bus_index: int = AudioServer.get_bus_index(bus_name)
		if bus_index == -1:
			continue
		var base_volume_db: float = float(bus_config.get("volume_db", 0.0))
		var linear := bgm_linear if bus_name == "BGM" else sfx_linear
		var mix_db := linear_to_db(maxf(linear, MIN_LINEAR))
		AudioServer.set_bus_volume_db(bus_index, base_volume_db + mix_db)
