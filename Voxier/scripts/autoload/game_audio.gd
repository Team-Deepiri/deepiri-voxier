extends Node

const _BusIds := preload("res://scripts/audio/bus_ids.gd")
const _AudioIds := preload("res://scripts/audio/audio_ids.gd")
const _SettingsKeys := preload("res://scripts/save/settings_keys.gd")

const POOL_SIZE := 16
const MUSIC_FADE_SEC := 1.1
const WARNING_PULSE_SEC := 0.55
const SCORE_SFX_COOLDOWN := 0.08

var _streams: Dictionary = {}
var _defs: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _music_layers: Dictionary = {}
var _music_mood := _AudioIds.MOOD_MENU
var _music_tween: Tween
var _warning_player: AudioStreamPlayer
var _warning_pulse := 0.0
var _fire_alt_next := false
var _score_sfx_cd := 0.0
var _settings := preload("res://scripts/save/local_settings.gd").new()

var sfx_volume_linear := 1.0
var music_volume_linear := 1.0
var audio_enabled := true


func _ready() -> void:
	_build_catalog()
	_load_volume_settings()
	_build_pool()
	_build_music()
	_build_warning_loop()
	EventBus.sfx_requested.connect(_on_sfx_requested)
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.game_state_changed.connect(_on_game_state_changed)
	EventBus.camera_shake_requested.connect(_on_camera_shake)
	call_deferred("_sync_music_to_scene")


func _process(delta: float) -> void:
	if _score_sfx_cd > 0.0:
		_score_sfx_cd -= delta
	_tick_warning_pulse(delta)
	_tick_combat_music()


func _build_catalog() -> void:
	_defs = {
		_AudioIds.FIRE: {"path": "res://audio/sfx/fire.ogg", "bus": _BusIds.SFX, "vol": -4.0, "pitch": [0.92, 1.08]},
		_AudioIds.FIRE_ALT: {"path": "res://audio/sfx/fire_alt.ogg", "bus": _BusIds.SFX, "vol": -5.0, "pitch": [0.9, 1.1]},
		_AudioIds.EXPLOSION: {"path": "res://audio/sfx/explosion.ogg", "bus": _BusIds.SFX, "vol": -2.0, "pitch": [0.85, 1.0]},
		_AudioIds.HURT: {"path": "res://audio/sfx/hurt.ogg", "bus": _BusIds.SFX, "vol": -1.0, "pitch": [0.95, 1.05]},
		_AudioIds.HOP: {"path": "res://audio/sfx/hop.ogg", "bus": _BusIds.SFX, "vol": 0.0, "pitch": [0.98, 1.12]},
		_AudioIds.ENEMY_DIE: {"path": "res://audio/sfx/enemy_die.ogg", "bus": _BusIds.SFX, "vol": -3.0, "pitch": [0.88, 1.15]},
		_AudioIds.BONUS: {"path": "res://audio/sfx/bonus.ogg", "bus": _BusIds.SFX, "vol": -2.0, "pitch": [0.95, 1.05]},
		_AudioIds.PICKUP: {"path": "res://audio/sfx/pickup.ogg", "bus": _BusIds.SFX, "vol": -4.0, "pitch": [0.98, 1.02]},
		_AudioIds.ROTATE: {"path": "res://audio/sfx/rotate.ogg", "bus": _BusIds.SFX, "vol": -3.0, "pitch": [0.9, 1.1]},
		_AudioIds.WARNING: {"path": "res://audio/sfx/warning.ogg", "bus": _BusIds.SFX, "vol": -6.0, "pitch": [0.95, 1.05]},
		_AudioIds.HIT: {"path": "res://audio/sfx/hit.ogg", "bus": _BusIds.SFX, "vol": -5.0, "pitch": [0.9, 1.1]},
		_AudioIds.PLAYER_DIE: {"path": "res://audio/sfx/player_die.ogg", "bus": _BusIds.SFX, "vol": 0.0, "pitch": [0.95, 1.0]},
		_AudioIds.SCORE: {"path": "res://audio/sfx/score.ogg", "bus": _BusIds.SFX, "vol": -10.0, "pitch": [1.0, 1.25]},
		_AudioIds.ROCKET_SPAWN: {"path": "res://audio/sfx/rocket_spawn.ogg", "bus": _BusIds.SFX, "vol": -5.0, "pitch": [0.95, 1.05]},
		_AudioIds.MISS: {"path": "res://audio/sfx/miss.ogg", "bus": _BusIds.SFX, "vol": -2.0, "pitch": [0.98, 1.02]},
		_AudioIds.UI_CLICK: {"path": "res://audio/sfx/ui_click.ogg", "bus": _BusIds.UI, "vol": -6.0, "pitch": [0.98, 1.02]},
		_AudioIds.UI_HOVER: {"path": "res://audio/sfx/ui_hover.ogg", "bus": _BusIds.UI, "vol": -12.0, "pitch": [0.95, 1.05]},
		_AudioIds.UI_BACK: {"path": "res://audio/sfx/ui_back.ogg", "bus": _BusIds.UI, "vol": -5.0, "pitch": [1.0, 1.0]},
		_AudioIds.GAME_START: {"path": "res://audio/sfx/game_start.ogg", "bus": _BusIds.UI, "vol": -3.0, "pitch": [1.0, 1.0]},
		_AudioIds.GAME_OVER: {"path": "res://audio/sfx/game_over.ogg", "bus": _BusIds.UI, "vol": -1.0, "pitch": [1.0, 1.0]},
	}
	for id in _defs:
		var def: Dictionary = _defs[id]
		_streams[id] = _load_stream(def["path"])


func _build_pool() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = _BusIds.SFX
		add_child(p)
		_pool.append(p)


func _build_music() -> void:
	var tracks := {
		_AudioIds.MOOD_MENU: "res://audio/music/menu_loop.ogg",
		_AudioIds.MOOD_GAME: "res://audio/music/game_loop.ogg",
		_AudioIds.MOOD_COMBAT: "res://audio/music/combat_loop.ogg",
	}
	for mood_key in tracks.keys():
		var mood: StringName = mood_key
		var player := AudioStreamPlayer.new()
		player.bus = _BusIds.MUSIC
		player.volume_db = -14.0
		var stream := _load_stream(String(tracks[mood]))
		if stream:
			_prepare_loop(stream)
			player.stream = stream
		add_child(player)
		_music_layers[mood] = player


func _build_warning_loop() -> void:
	_warning_player = AudioStreamPlayer.new()
	_warning_player.bus = _BusIds.SFX
	_warning_player.volume_db = -8.0
	var w: AudioStream = _streams.get(_AudioIds.WARNING) as AudioStream
	if w != null:
		_warning_player.stream = w
	add_child(_warning_player)


func _load_stream(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("GameAudio: missing %s" % path)
		return null
	return load(path) as AudioStream


func _prepare_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD


func _load_volume_settings() -> void:
	sfx_volume_linear = clampf(_settings.read_float(_SettingsKeys.AUDIO_SFX_VOLUME, 1.0), 0.0, 1.0)
	music_volume_linear = clampf(_settings.read_float(_SettingsKeys.AUDIO_MUSIC_VOLUME, 0.85), 0.0, 1.0)
	audio_enabled = _settings.read_int(_SettingsKeys.AUDIO_ENABLED, 1) != 0
	_apply_bus_volumes()


func _apply_bus_volumes() -> void:
	var master_idx := AudioServer.get_bus_index(_BusIds.MASTER)
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, 0.0 if audio_enabled else -80.0)
	var sfx_idx := AudioServer.get_bus_index(_BusIds.SFX)
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume_linear))
	var ui_idx := AudioServer.get_bus_index(_BusIds.UI)
	if ui_idx >= 0:
		AudioServer.set_bus_volume_db(ui_idx, linear_to_db(sfx_volume_linear * 0.95))
	var music_idx := AudioServer.get_bus_index(_BusIds.MUSIC)
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume_linear))


func set_sfx_volume(linear: float) -> void:
	sfx_volume_linear = clampf(linear, 0.0, 1.0)
	_settings.write_float(_SettingsKeys.AUDIO_SFX_VOLUME, sfx_volume_linear)
	_apply_bus_volumes()


func set_music_volume(linear: float) -> void:
	music_volume_linear = clampf(linear, 0.0, 1.0)
	_settings.write_float(_SettingsKeys.AUDIO_MUSIC_VOLUME, music_volume_linear)
	_apply_bus_volumes()


func set_audio_enabled(enabled: bool) -> void:
	audio_enabled = enabled
	_settings.write_int(_SettingsKeys.AUDIO_ENABLED, 1 if enabled else 0)
	_apply_bus_volumes()


func play_sfx(id: StringName, volume_offset_db: float = 0.0) -> void:
	if not audio_enabled:
		return
	_play_sfx(id, volume_offset_db)


func play_ui(id: StringName) -> void:
	play_sfx(id)


func play_fire() -> void:
	var id: StringName = _AudioIds.FIRE_ALT if _fire_alt_next else _AudioIds.FIRE
	_fire_alt_next = not _fire_alt_next
	play_sfx(id)


func set_music_mood(mood: StringName) -> void:
	if mood == _music_mood:
		return
	_music_mood = mood
	_crossfade_music(mood)


func _sync_music_to_scene() -> void:
	var gm := get_node_or_null("/root/GameManager")
	if gm == null:
		set_music_mood(_AudioIds.MOOD_MENU)
		return
	match gm.state:
		gm.GameState.MENU:
			set_music_mood(_AudioIds.MOOD_MENU)
		gm.GameState.GAME_OVER:
			set_music_mood(_AudioIds.MOOD_GAME_OVER)
		gm.GameState.PLAYING, gm.GameState.FALLING, gm.GameState.ROCKET_CHANGE:
			set_music_mood(_AudioIds.MOOD_GAME)
		_:
			set_music_mood(_AudioIds.MOOD_MENU)


func _crossfade_music(mood: StringName) -> void:
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	for key_variant in _music_layers.keys():
		var key: StringName = key_variant
		var player: AudioStreamPlayer = _music_layers[key]
		var target_db := -80.0
		var should_play: bool = key == mood
		if mood == _AudioIds.MOOD_GAME_OVER and key == _AudioIds.MOOD_GAME:
			should_play = true
			target_db = -22.0
		elif should_play:
			target_db = -14.0 if key != _AudioIds.MOOD_COMBAT else -11.0
		if should_play and not player.playing:
			player.play()
		_music_tween.tween_property(player, "volume_db", target_db, MUSIC_FADE_SEC)
	if mood == _AudioIds.MOOD_GAME_OVER:
		play_sfx(_AudioIds.GAME_OVER)
		var sting := _load_stream("res://audio/music/sting_game_over.ogg")
		if sting:
			_play_one_shot(sting, _BusIds.SFX, -4.0, 1.0)


func _tick_combat_music() -> void:
	if _music_mood != _AudioIds.MOOD_GAME and _music_mood != _AudioIds.MOOD_COMBAT:
		return
	var gm := get_node_or_null("/root/GameManager")
	if gm == null or gm.state != gm.GameState.PLAYING:
		if _music_mood == _AudioIds.MOOD_COMBAT:
			set_music_mood(_AudioIds.MOOD_GAME)
		return
	var spawner := get_tree().get_first_node_in_group("enemy_spawner")
	var active := 0
	if spawner and spawner.has_method("get_active_enemy_count"):
		active = spawner.get_active_enemy_count()
	var want_combat := active >= 4
	var next := _AudioIds.MOOD_COMBAT if want_combat else _AudioIds.MOOD_GAME
	if next != _music_mood:
		set_music_mood(next)


func _tick_warning_pulse(delta: float) -> void:
	var gm := get_node_or_null("/root/GameManager")
	var falling: bool = (
		gm != null and gm.state == gm.GameState.FALLING and gm.has_new_rocket
	)
	if not falling or not audio_enabled:
		if _warning_player.playing:
			_warning_player.stop()
		return
	_warning_pulse -= delta
	if _warning_pulse <= 0.0:
		_warning_pulse = WARNING_PULSE_SEC
		if not _warning_player.playing:
			_warning_player.play()
		else:
			_warning_player.play(_warning_player.get_playback_position() + 0.01)


func _on_sfx_requested(id: StringName) -> void:
	_play_sfx(id, 0.0)


func _play_sfx(id: StringName, volume_offset_db: float = 0.0) -> void:
	var stream: AudioStream = _streams.get(id) as AudioStream
	if stream == null:
		return
	var def: Dictionary = _defs.get(id, {})
	var bus: StringName = def.get("bus", _BusIds.SFX) as StringName
	var vol: float = float(def.get("vol", 0.0)) + volume_offset_db
	var pitch_rng: Array = def.get("pitch", [1.0, 1.0]) as Array
	var ps := randf_range(float(pitch_rng[0]), float(pitch_rng[1]))
	_play_one_shot(stream, bus, vol, ps)


func _play_one_shot(stream: AudioStream, bus: StringName, volume_db: float, pitch_scale: float) -> void:
	for p in _pool:
		if not p.playing:
			p.bus = bus
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = pitch_scale if pitch_scale > 0.01 else 1.0
			p.play()
			return
	var p0 := _pool[0]
	p0.bus = bus
	p0.stream = stream
	p0.volume_db = volume_db
	p0.pitch_scale = pitch_scale if pitch_scale > 0.01 else 1.0
	p0.play()


func _on_score_changed(_new_total: int) -> void:
	if _score_sfx_cd > 0.0:
		return
	_score_sfx_cd = SCORE_SFX_COOLDOWN
	play_sfx(_AudioIds.SCORE)


func _on_game_state_changed(_new_state: int) -> void:
	call_deferred("_sync_music_to_scene")


func _on_camera_shake(trauma: float) -> void:
	if trauma < 0.35:
		return
	play_sfx(_AudioIds.EXPLOSION, -14.0)
