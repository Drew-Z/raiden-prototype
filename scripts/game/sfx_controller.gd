extends Node
class_name SfxController

const AudioBusSetupScript := preload("res://scripts/autoload/audio_bus_setup.gd")
const SAMPLE_BASE_PATH := "res://assets/audio/sfx"
const SAMPLE_EXTENSIONS := ["wav"]
const SAMPLE_VARIANT_COUNTS := {
	"player_shot": 3,
	"enemy_hit": 3,
	"enemy_destroy": 3,
	"player_hurt": 3,
	"player_die": 3,
	"boss_hit": 3,
	"power_up": 3,
	"bomb_pickup": 3,
	"bomb": 3,
	"boss_warning": 3,
	"boss_phase": 3,
	"boss_break": 3,
	"stage_clear": 3,
	"storm_charge": 3,
	"storm_impact": 3
}
const SAMPLE_VARIANT_GAIN_DB := {
	"player_shot": [-7.5, -8.2, -7.8],
	"enemy_hit": [-0.6, 0.0, -1.6],
	"enemy_destroy": [-1.4, 1.1, -0.3],
	"player_hurt": [-2.6, -0.9, 0.2],
	"boss_hit": [-1.8, -0.5, 0.6],
	"power_up": [-4.2, -3.2, -4.8],
	"bomb_pickup": [-5.0, -4.2, -4.6],
	"bomb": [-4.6, -2.2, -5.8],
	"boss_warning": [-7.2, -5.6, -4.4],
	"boss_break": [-2.8, -2.1, -2.4],
	"stage_clear": [-3.8, -6.2, -5.4],
	"storm_charge": [-3.6, -4.2, -4.8],
	"storm_impact": [-7.6, -4.2, -2.6]
}

var players: Array[AudioStreamPlayer] = []
var procedural_stream_cache: Dictionary = {}
var sample_cache: Dictionary = {}
var last_play_times: Dictionary = {}
var sample_rate := 22050


func _ready() -> void:
	AudioBusSetupScript.ensure_layout()
	for _index in range(14):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "SFX_UI"
		player.set_meta("play_id", 0)
		add_child(player)
		players.append(player)


func _exit_tree() -> void:
	for player in players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	procedural_stream_cache.clear()
	sample_cache.clear()
	last_play_times.clear()
	players.clear()


func play_event(event_name: String) -> void:
	var cooldown: float = _get_cooldown(event_name)
	var now_sec: float = float(Time.get_ticks_msec()) / 1000.0
	if cooldown > 0.0 and last_play_times.has(event_name):
		if now_sec - float(last_play_times[event_name]) < cooldown:
			return

	last_play_times[event_name] = now_sec
	var sample_entry := _get_sample_entry_for_event(event_name)
	var stream: AudioStream = sample_entry.get("stream", null)
	var sample_gain_db := float(sample_entry.get("gain_db", 0.0))
	if stream == null:
		stream = _get_procedural_stream_for_event(event_name)
		sample_gain_db = 0.0
	if stream == null:
		return

	var player: AudioStreamPlayer = _get_available_player()
	player.stop()
	player.bus = _get_bus_name(event_name)
	player.volume_db = _get_volume_db(event_name) + sample_gain_db
	player.pitch_scale = _get_pitch_scale(event_name)
	player.stream = stream
	var play_id := int(player.get_meta("play_id", 0)) + 1
	player.set_meta("play_id", play_id)
	player.play()
	var max_play_time := _get_max_play_time(event_name)
	if max_play_time > 0.0:
		get_tree().create_timer(max_play_time).timeout.connect(func() -> void:
			if is_instance_valid(player) and int(player.get_meta("play_id", 0)) == play_id and player.playing:
				player.stop()
		)


func _get_available_player() -> AudioStreamPlayer:
	for player in players:
		if not player.playing:
			return player
	return players[0]


func _get_sample_entry_for_event(event_name: String) -> Dictionary:
	var bank: Array = _get_sample_bank(event_name)
	if bank.is_empty():
		return {}
	return bank[randi() % bank.size()]


func _get_sample_bank(event_name: String) -> Array:
	if sample_cache.has(event_name):
		return sample_cache[event_name]

	var bank: Array = []
	var variant_count: int = int(SAMPLE_VARIANT_COUNTS.get(event_name, 0))
	for variant_index in range(1, variant_count + 1):
		for extension in SAMPLE_EXTENSIONS:
			var path: String = "%s/%s_%02d.%s" % [SAMPLE_BASE_PATH, event_name, variant_index, extension]
			if not ResourceLoader.exists(path):
				continue
			var stream := load(path)
			if stream is AudioStream:
				bank.append({
					"stream": stream,
					"gain_db": _get_sample_gain_db(event_name, variant_index)
				})
				break
	sample_cache[event_name] = bank
	return bank


func _get_sample_gain_db(event_name: String, variant_index: int) -> float:
	var gains: Array = SAMPLE_VARIANT_GAIN_DB.get(event_name, [])
	if gains.is_empty():
		return 0.0
	var gain_index := clampi(variant_index - 1, 0, gains.size() - 1)
	return float(gains[gain_index])


func _get_cooldown(event_name: String) -> float:
	match event_name:
		"player_shot":
			return 0.09
		"enemy_hit":
			return 0.06
		"enemy_destroy":
			return 0.055
		"player_hurt":
			return 0.12
		"boss_hit":
			return 0.065
		"storm_impact":
			return 0.16
		_:
			return 0.0


func _get_volume_db(event_name: String) -> float:
	match event_name:
		"player_shot":
			return -23.4
		"enemy_hit":
			return -17.0
		"enemy_destroy":
			return -6.4
		"player_hurt":
			return -17.5
		"player_die":
			return -9.0
		"boss_hit":
			return -9.2
		"power_up", "bomb_pickup":
			return -12.2
		"bomb":
			return -13.6
		"boss_warning":
			return -20.2
		"boss_phase":
			return -15.6
		"storm_charge":
			return -17.2
		"storm_impact":
			return -16.0
		"boss_break", "stage_clear":
			return -8.2
		_:
			return -7.0


func _get_pitch_scale(event_name: String) -> float:
	match event_name:
		"player_shot":
			return randf_range(0.99, 1.02)
		"enemy_hit":
			return randf_range(0.98, 1.01)
		"enemy_destroy":
			return randf_range(0.97, 1.01)
		"boss_hit":
			return randf_range(0.98, 1.01)
		"storm_charge":
			return randf_range(0.98, 1.01)
		"storm_impact":
			return randf_range(0.99, 1.01)
		"player_hurt":
			return randf_range(0.99, 1.01)
		_:
			return 1.0


func _get_bus_name(event_name: String) -> String:
	match event_name:
		"player_shot", "player_hurt", "player_die", "bomb":
			return "SFX_Player"
		"enemy_hit", "enemy_destroy":
			return "SFX_Enemy"
		"boss_hit", "boss_warning", "boss_phase", "boss_break":
			return "SFX_Boss"
		"storm_charge", "storm_impact":
			return "SFX_Boss"
		"power_up", "bomb_pickup", "stage_clear":
			return "SFX_UI"
		_:
			return "SFX_UI"


func _get_max_play_time(event_name: String) -> float:
	match event_name:
		"player_shot":
			return 0.14
		"enemy_hit":
			return 0.14
		"enemy_destroy":
			return 0.28
		"player_hurt":
			return 0.22
		"player_die":
			return 0.48
		"boss_hit":
			return 0.24
		"power_up":
			return 0.24
		"bomb_pickup":
			return 0.24
		"bomb":
			return 0.42
		"boss_warning":
			return 0.22
		"boss_phase":
			return 0.28
		"storm_charge":
			return 0.24
		"storm_impact":
			return 0.3
		"boss_break":
			return 0.52
		"stage_clear":
			return 0.64
		_:
			return 0.0


func _get_procedural_stream_for_event(event_name: String) -> AudioStreamWAV:
	if procedural_stream_cache.has(event_name):
		return procedural_stream_cache[event_name]

	var segments: Array[Dictionary] = []
	match event_name:
		"player_shot":
			segments = [
				{"freq": 420.0, "duration": 0.016, "volume": 0.058, "wave": "triangle"},
				{"freq": 300.0, "duration": 0.028, "volume": 0.028, "wave": "sine"}
			]
		"enemy_hit":
			segments = [
				{"freq": 150.0, "duration": 0.018, "volume": 0.035, "wave": "triangle"},
				{"freq": 190.0, "duration": 0.018, "volume": 0.02, "wave": "sine"}
			]
		"enemy_destroy":
			segments = [
				{"freq": 140.0, "duration": 0.036, "volume": 0.075, "wave": "triangle"},
				{"freq": 100.0, "duration": 0.058, "volume": 0.062, "wave": "sine"},
				{"freq": 220.0, "duration": 0.02, "volume": 0.018, "wave": "noise"}
			]
		"boss_hit":
			segments = [
				{"freq": 190.0, "duration": 0.04, "volume": 0.12, "wave": "triangle"},
				{"freq": 145.0, "duration": 0.052, "volume": 0.068, "wave": "square"}
			]
		"player_hurt":
			segments = [
				{"freq": 170.0, "duration": 0.055, "volume": 0.16, "wave": "triangle"},
				{"freq": 126.0, "duration": 0.05, "volume": 0.1, "wave": "square"}
			]
		"player_die":
			segments = [
				{"freq": 210.0, "duration": 0.1, "volume": 0.22, "wave": "triangle"},
				{"freq": 120.0, "duration": 0.12, "volume": 0.16, "wave": "square"},
				{"freq": 80.0, "duration": 0.16, "volume": 0.12, "wave": "triangle"}
			]
		"power_up":
			segments = [
				{"freq": 620.0, "duration": 0.028, "volume": 0.14, "wave": "sine"},
				{"freq": 780.0, "duration": 0.04, "volume": 0.13, "wave": "sine"}
			]
		"bomb_pickup":
			segments = [
				{"freq": 360.0, "duration": 0.038, "volume": 0.15, "wave": "triangle"},
				{"freq": 540.0, "duration": 0.056, "volume": 0.12, "wave": "square"}
			]
		"bomb":
			segments = [
				{"freq": 180.0, "duration": 0.08, "volume": 0.24, "wave": "square"},
				{"freq": 130.0, "duration": 0.12, "volume": 0.18, "wave": "triangle"},
				{"freq": 90.0, "duration": 0.18, "volume": 0.14, "wave": "triangle"}
			]
		"boss_warning":
			segments = [
				{"freq": 180.0, "duration": 0.08, "volume": 0.22, "wave": "square"},
				{"freq": 220.0, "duration": 0.08, "volume": 0.18, "wave": "square"}
			]
		"boss_phase":
			segments = [
				{"freq": 320.0, "duration": 0.05, "volume": 0.16, "wave": "square"},
				{"freq": 420.0, "duration": 0.05, "volume": 0.14, "wave": "square"},
				{"freq": 520.0, "duration": 0.08, "volume": 0.12, "wave": "sine"}
			]
		"boss_break":
			segments = [
				{"freq": 240.0, "duration": 0.08, "volume": 0.2, "wave": "square"},
				{"freq": 180.0, "duration": 0.1, "volume": 0.16, "wave": "triangle"},
				{"freq": 130.0, "duration": 0.12, "volume": 0.12, "wave": "triangle"}
			]
		"stage_clear":
			segments = [
				{"freq": 480.0, "duration": 0.05, "volume": 0.14, "wave": "sine"},
				{"freq": 620.0, "duration": 0.06, "volume": 0.14, "wave": "sine"},
				{"freq": 820.0, "duration": 0.1, "volume": 0.12, "wave": "sine"}
			]
		"storm_charge":
			segments = [
				{"freq": 140.0, "duration": 0.08, "volume": 0.14, "wave": "triangle"},
				{"freq": 220.0, "duration": 0.12, "volume": 0.1, "wave": "sine"},
				{"freq": 260.0, "duration": 0.08, "volume": 0.05, "wave": "noise"}
			]
		"storm_impact":
			segments = [
				{"freq": 100.0, "duration": 0.1, "volume": 0.2, "wave": "triangle"},
				{"freq": 160.0, "duration": 0.14, "volume": 0.14, "wave": "square"},
				{"freq": 260.0, "duration": 0.06, "volume": 0.05, "wave": "noise"}
			]
		_:
			return null

	var stream: AudioStreamWAV = _build_stream(segments)
	procedural_stream_cache[event_name] = stream
	return stream


func _build_stream(segments: Array[Dictionary]) -> AudioStreamWAV:
	var data := PackedByteArray()
	for segment in segments:
		_append_segment(data, segment)
		_append_silence(data, 0.004)

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _append_segment(target: PackedByteArray, segment: Dictionary) -> void:
	var freq: float = float(segment.get("freq", 440.0))
	var duration: float = float(segment.get("duration", 0.06))
	var volume: float = float(segment.get("volume", 0.16))
	var wave: String = String(segment.get("wave", "sine"))
	var sample_count: int = max(1, int(round(duration * float(sample_rate))))

	for index in range(sample_count):
		var ratio: float = float(index) / float(sample_count)
		var envelope: float = _envelope(ratio)
		var sample: float = _wave_sample(wave, freq, float(index) / float(sample_rate))
		var pcm_value: int = int(round(clampf(sample * envelope * volume, -1.0, 1.0) * 32767.0))
		target.append(pcm_value & 0xFF)
		target.append((pcm_value >> 8) & 0xFF)


func _append_silence(target: PackedByteArray, duration: float) -> void:
	var sample_count: int = max(1, int(round(duration * float(sample_rate))))
	for _index in range(sample_count):
		target.append(0)
		target.append(0)


func _envelope(ratio: float) -> float:
	if ratio < 0.08:
		return ratio / 0.08
	if ratio > 0.72:
		return max(0.0, 1.0 - (ratio - 0.72) / 0.28)
	return 1.0


func _wave_sample(wave: String, freq: float, t: float) -> float:
	var phase: float = t * freq
	match wave:
		"square":
			return 1.0 if sin(TAU * phase) >= 0.0 else -1.0
		"triangle":
			return asin(sin(TAU * phase)) * (2.0 / PI)
		"noise":
			return randf_range(-1.0, 1.0)
		_:
			return sin(TAU * phase)
