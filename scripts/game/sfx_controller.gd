extends Node
class_name SfxController

var players: Array[AudioStreamPlayer] = []
var stream_cache: Dictionary = {}
var last_play_times: Dictionary = {}
var sample_rate := 22050


func _ready() -> void:
	for _index in range(10):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		players.append(player)


func _exit_tree() -> void:
	for player in players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	stream_cache.clear()
	last_play_times.clear()
	players.clear()


func play_event(event_name: String) -> void:
	var cooldown: float = _get_cooldown(event_name)
	var now_sec: float = float(Time.get_ticks_msec()) / 1000.0
	if cooldown > 0.0 and last_play_times.has(event_name):
		if now_sec - float(last_play_times[event_name]) < cooldown:
			return

	last_play_times[event_name] = now_sec
	var stream: AudioStreamWAV = _get_stream_for_event(event_name)
	if stream == null:
		return

	var player: AudioStreamPlayer = _get_available_player()
	player.stream = stream
	player.play()


func _get_available_player() -> AudioStreamPlayer:
	for player in players:
		if not player.playing:
			return player
	return players[0]


func _get_cooldown(event_name: String) -> float:
	match event_name:
		"player_shot":
			return 0.05
		"enemy_hit":
			return 0.025
		_:
			return 0.0


func _get_stream_for_event(event_name: String) -> AudioStreamWAV:
	if stream_cache.has(event_name):
		return stream_cache[event_name]

	var segments: Array[Dictionary] = []
	match event_name:
		"player_shot":
			segments = [
				{"freq": 980.0, "duration": 0.022, "volume": 0.18, "wave": "square"},
				{"freq": 720.0, "duration": 0.028, "volume": 0.12, "wave": "triangle"}
			]
		"enemy_hit":
			segments = [
				{"freq": 420.0, "duration": 0.018, "volume": 0.12, "wave": "square"}
			]
		"enemy_destroy":
			segments = [
				{"freq": 260.0, "duration": 0.035, "volume": 0.2, "wave": "square"},
				{"freq": 180.0, "duration": 0.06, "volume": 0.16, "wave": "triangle"}
			]
		"boss_hit":
			segments = [
				{"freq": 220.0, "duration": 0.032, "volume": 0.22, "wave": "square"},
				{"freq": 180.0, "duration": 0.05, "volume": 0.18, "wave": "triangle"}
			]
		"player_hurt":
			segments = [
				{"freq": 170.0, "duration": 0.08, "volume": 0.24, "wave": "triangle"},
				{"freq": 120.0, "duration": 0.08, "volume": 0.18, "wave": "square"}
			]
		"player_die":
			segments = [
				{"freq": 210.0, "duration": 0.12, "volume": 0.26, "wave": "triangle"},
				{"freq": 120.0, "duration": 0.12, "volume": 0.18, "wave": "square"},
				{"freq": 80.0, "duration": 0.16, "volume": 0.12, "wave": "triangle"}
			]
		"power_up":
			segments = [
				{"freq": 660.0, "duration": 0.03, "volume": 0.16, "wave": "sine"},
				{"freq": 820.0, "duration": 0.04, "volume": 0.15, "wave": "sine"}
			]
		"bomb_pickup":
			segments = [
				{"freq": 420.0, "duration": 0.04, "volume": 0.18, "wave": "triangle"},
				{"freq": 620.0, "duration": 0.06, "volume": 0.16, "wave": "square"}
			]
		"bomb":
			segments = [
				{"freq": 180.0, "duration": 0.08, "volume": 0.28, "wave": "square"},
				{"freq": 130.0, "duration": 0.12, "volume": 0.2, "wave": "triangle"},
				{"freq": 90.0, "duration": 0.16, "volume": 0.14, "wave": "triangle"}
			]
		"boss_warning":
			segments = [
				{"freq": 180.0, "duration": 0.08, "volume": 0.24, "wave": "square"},
				{"freq": 220.0, "duration": 0.08, "volume": 0.2, "wave": "square"}
			]
		"boss_phase":
			segments = [
				{"freq": 320.0, "duration": 0.05, "volume": 0.18, "wave": "square"},
				{"freq": 420.0, "duration": 0.05, "volume": 0.16, "wave": "square"},
				{"freq": 520.0, "duration": 0.08, "volume": 0.14, "wave": "sine"}
			]
		"boss_break":
			segments = [
				{"freq": 240.0, "duration": 0.08, "volume": 0.22, "wave": "square"},
				{"freq": 180.0, "duration": 0.1, "volume": 0.18, "wave": "triangle"},
				{"freq": 130.0, "duration": 0.12, "volume": 0.14, "wave": "triangle"}
			]
		"stage_clear":
			segments = [
				{"freq": 520.0, "duration": 0.05, "volume": 0.16, "wave": "sine"},
				{"freq": 660.0, "duration": 0.06, "volume": 0.16, "wave": "sine"},
				{"freq": 880.0, "duration": 0.1, "volume": 0.14, "wave": "sine"}
			]
		_:
			return null

	var stream: AudioStreamWAV = _build_stream(segments)
	stream_cache[event_name] = stream
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
		_:
			return sin(TAU * phase)
