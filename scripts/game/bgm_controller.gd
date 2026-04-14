extends Node
class_name BgmController

var loop_player: AudioStreamPlayer
var sting_player: AudioStreamPlayer
var stream_cache: Dictionary = {}
var sample_rate := 22050


func _ready() -> void:
	loop_player = AudioStreamPlayer.new()
	loop_player.bus = "Master"
	loop_player.volume_db = -18.0
	add_child(loop_player)

	sting_player = AudioStreamPlayer.new()
	sting_player.bus = "Master"
	sting_player.volume_db = -14.0
	add_child(sting_player)


func play_stage_loop() -> void:
	_play_loop("stage_loop")


func play_boss_loop() -> void:
	_play_loop("boss_loop")


func play_boss_overdrive_loop() -> void:
	_play_loop("boss_overdrive_loop")


func play_clear_sting() -> void:
	_play_sting("clear_sting")


func play_chapter_end_sting() -> void:
	_play_sting("chapter_end_sting")


func play_fail_sting() -> void:
	_play_sting("fail_sting")


func stop_all() -> void:
	if is_instance_valid(loop_player):
		loop_player.stop()
	if is_instance_valid(sting_player):
		sting_player.stop()


func _play_loop(track_name: String) -> void:
	var stream: AudioStreamWAV = _get_stream(track_name)
	if stream == null or not is_instance_valid(loop_player):
		return
	if loop_player.stream == stream and loop_player.playing:
		return
	loop_player.stop()
	loop_player.stream = stream
	loop_player.play()


func _play_sting(track_name: String) -> void:
	var stream: AudioStreamWAV = _get_stream(track_name)
	if stream == null or not is_instance_valid(sting_player):
		return
	sting_player.stop()
	sting_player.stream = stream
	sting_player.play()


func _get_stream(track_name: String) -> AudioStreamWAV:
	if stream_cache.has(track_name):
		return stream_cache[track_name]

	var stream: AudioStreamWAV = null
	match track_name:
		"stage_loop":
			stream = _build_loop_stream([
				{"freq": 164.81, "duration": 0.18, "volume": 0.08, "wave": "triangle"},
				{"freq": 220.00, "duration": 0.18, "volume": 0.075, "wave": "triangle"},
				{"freq": 246.94, "duration": 0.18, "volume": 0.07, "wave": "triangle"},
				{"freq": 220.00, "duration": 0.18, "volume": 0.075, "wave": "triangle"},
				{"freq": 174.61, "duration": 0.18, "volume": 0.08, "wave": "triangle"},
				{"freq": 220.00, "duration": 0.18, "volume": 0.075, "wave": "triangle"},
				{"freq": 261.63, "duration": 0.18, "volume": 0.07, "wave": "triangle"},
				{"freq": 220.00, "duration": 0.18, "volume": 0.075, "wave": "triangle"}
			], 0.01)
		"boss_loop":
			stream = _build_loop_stream([
				{"freq": 130.81, "duration": 0.16, "volume": 0.1, "wave": "square"},
				{"freq": 196.00, "duration": 0.14, "volume": 0.085, "wave": "triangle"},
				{"freq": 164.81, "duration": 0.14, "volume": 0.09, "wave": "square"},
				{"freq": 196.00, "duration": 0.14, "volume": 0.085, "wave": "triangle"},
				{"freq": 146.83, "duration": 0.16, "volume": 0.1, "wave": "square"},
				{"freq": 220.00, "duration": 0.14, "volume": 0.082, "wave": "triangle"},
				{"freq": 174.61, "duration": 0.14, "volume": 0.09, "wave": "square"},
				{"freq": 220.00, "duration": 0.14, "volume": 0.082, "wave": "triangle"}
			], 0.008)
		"boss_overdrive_loop":
			stream = _build_loop_stream([
				{"freq": 164.81, "duration": 0.12, "volume": 0.11, "wave": "square"},
				{"freq": 246.94, "duration": 0.1, "volume": 0.09, "wave": "triangle"},
				{"freq": 196.00, "duration": 0.1, "volume": 0.105, "wave": "square"},
				{"freq": 261.63, "duration": 0.1, "volume": 0.09, "wave": "triangle"},
				{"freq": 174.61, "duration": 0.12, "volume": 0.11, "wave": "square"},
				{"freq": 293.66, "duration": 0.1, "volume": 0.088, "wave": "triangle"},
				{"freq": 220.00, "duration": 0.1, "volume": 0.105, "wave": "square"},
				{"freq": 329.63, "duration": 0.1, "volume": 0.086, "wave": "triangle"}
			], 0.006)
		"clear_sting":
			stream = _build_one_shot_stream([
				{"freq": 523.25, "duration": 0.07, "volume": 0.12, "wave": "sine"},
				{"freq": 659.25, "duration": 0.08, "volume": 0.12, "wave": "sine"},
				{"freq": 783.99, "duration": 0.12, "volume": 0.11, "wave": "sine"}
			], 0.018)
		"chapter_end_sting":
			stream = _build_one_shot_stream([
				{"freq": 392.00, "duration": 0.08, "volume": 0.11, "wave": "triangle"},
				{"freq": 523.25, "duration": 0.08, "volume": 0.11, "wave": "triangle"},
				{"freq": 659.25, "duration": 0.1, "volume": 0.12, "wave": "sine"},
				{"freq": 783.99, "duration": 0.14, "volume": 0.12, "wave": "sine"}
			], 0.02)
		"fail_sting":
			stream = _build_one_shot_stream([
				{"freq": 246.94, "duration": 0.08, "volume": 0.12, "wave": "triangle"},
				{"freq": 196.00, "duration": 0.1, "volume": 0.11, "wave": "triangle"},
				{"freq": 146.83, "duration": 0.12, "volume": 0.1, "wave": "triangle"}
			], 0.018)
		_:
			return null

	stream_cache[track_name] = stream
	return stream


func _build_loop_stream(notes: Array[Dictionary], gap_duration: float) -> AudioStreamWAV:
	var data := PackedByteArray()
	for note in notes:
		_append_segment(data, note)
		_append_silence(data, gap_duration)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = data.size() / 2
	return stream


func _build_one_shot_stream(notes: Array[Dictionary], gap_duration: float) -> AudioStreamWAV:
	var data := PackedByteArray()
	for note in notes:
		_append_segment(data, note)
		_append_silence(data, gap_duration)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _append_segment(target: PackedByteArray, segment: Dictionary) -> void:
	var freq: float = float(segment.get("freq", 440.0))
	var duration: float = float(segment.get("duration", 0.08))
	var volume: float = float(segment.get("volume", 0.1))
	var wave: String = String(segment.get("wave", "sine"))
	var sample_count: int = max(1, int(round(duration * float(sample_rate))))

	for index in range(sample_count):
		var ratio := float(index) / float(sample_count)
		var envelope := _envelope(ratio)
		var sample := _wave_sample(wave, freq, float(index) / float(sample_rate))
		var pcm_value: int = int(round(clampf(sample * envelope * volume, -1.0, 1.0) * 32767.0))
		target.append(pcm_value & 0xFF)
		target.append((pcm_value >> 8) & 0xFF)


func _append_silence(target: PackedByteArray, duration: float) -> void:
	var sample_count: int = max(1, int(round(duration * float(sample_rate))))
	for _index in range(sample_count):
		target.append(0)
		target.append(0)


func _envelope(ratio: float) -> float:
	if ratio < 0.1:
		return ratio / 0.1
	if ratio > 0.72:
		return max(0.0, 1.0 - (ratio - 0.72) / 0.28)
	return 1.0


func _wave_sample(wave: String, freq: float, t: float) -> float:
	var phase := t * freq
	match wave:
		"square":
			return 1.0 if sin(TAU * phase) >= 0.0 else -1.0
		"triangle":
			return asin(sin(TAU * phase)) * (2.0 / PI)
		_:
			return sin(TAU * phase)
