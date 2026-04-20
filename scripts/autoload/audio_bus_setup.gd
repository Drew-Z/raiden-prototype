extends Node

const BUS_CONFIGS := [
	{"name": "BGM", "volume_db": -8.0},
	{"name": "SFX_Player", "volume_db": -4.5},
	{"name": "SFX_Enemy", "volume_db": -2.8},
	{"name": "SFX_Boss", "volume_db": -1.5},
	{"name": "SFX_UI", "volume_db": -4.0}
]


func _ready() -> void:
	ensure_layout()


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
		AudioServer.set_bus_volume_db(bus_index, float(bus_config.get("volume_db", 0.0)))
