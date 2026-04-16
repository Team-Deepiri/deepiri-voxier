extends Node

const POOL_SIZE := 10

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer

func _ready() -> void:
	_streams = {
		&"fire": _try_load("res://audio/sfx/fire.wav"),
		&"explosion": _try_load("res://audio/sfx/explosion.wav"),
		&"hurt": _try_load("res://audio/sfx/hurt.wav"),
		&"hop": _try_load("res://audio/sfx/hop.wav"),
		&"enemy_die": _try_load("res://audio/sfx/enemy_die.wav"),
		&"bonus": _try_load("res://audio/sfx/bonus.wav"),
		&"pickup": _try_load("res://audio/sfx/pickup.wav"),
	}
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = &"Master"
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = &"Master"
	_music.volume_db = -8.0
	add_child(_music)
	EventBus.sfx_requested.connect(_on_sfx_requested)
	call_deferred("_start_music")

func _try_load(path: String) -> AudioStream:
	var res := load(path)
	return res as AudioStream

func _start_music() -> void:
	var stream := _try_load("res://audio/music/orbit_drone.wav")
	if stream == null:
		return
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_music.stream = stream
	_music.play()

func _on_sfx_requested(id: StringName) -> void:
	var stream: AudioStream = _streams.get(id, null)
	if stream == null:
		return
	var ps := 1.0
	if id == &"fire" or id == &"enemy_die":
		ps = randf_range(0.9, 1.12)
	_play_one_shot(stream, ps)

func _play_one_shot(stream: AudioStream, pitch_scale: float) -> void:
	for p in _pool:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch_scale if pitch_scale > 0.01 else 1.0
			p.play()
			return
	var p0 := _pool[0]
	p0.stream = stream
	p0.pitch_scale = pitch_scale if pitch_scale > 0.01 else 1.0
	p0.play()
