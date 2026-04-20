extends Node

const BUS_CONFIGS := [
	{"name": "BGM", "volume_db": -8.0},
	{"name": "SFX_Player", "volume_db": -4.5},
	{"name": "SFX_Enemy", "volume_db": -2.8},
	{"name": "SFX_Boss", "volume_db": -1.5},
	{"name": "SFX_UI", "volume_db": -4.0}
]
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
