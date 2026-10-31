extends Node

## SoundManager
## Audio singleton managing SFX and BGM playback, respecting volume settings from SaveSystem.

var sfx_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer

var streams: Dictionary = {}

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	add_child(bgm_player)
	
	_load_streams()
	update_volumes()
	print("[SoundManager] Autoload initialized with %d audio streams." % streams.size())

func _load_streams() -> void:
	var files = {
		"click": "res://assets/audio/sfx_click.wav",
		"cash": "res://assets/audio/sfx_cash.wav",
		"success": "res://assets/audio/sfx_success.wav",
		"fail": "res://assets/audio/sfx_fail.wav",
		"event": "res://assets/audio/sfx_event.wav",
		"bgm": "res://assets/audio/bgm_market.wav"
	}
	
	for key in files:
		var path = files[key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream:
				streams[key] = stream

func update_volumes() -> void:
	var sfx_vol = 0.8
	var music_vol = 0.5
	if SaveSystem and SaveSystem.settings:
		sfx_vol = float(SaveSystem.settings.get("sfx_volume", 0.8))
		music_vol = float(SaveSystem.settings.get("music_volume", 0.5))
	
	if sfx_player:
		if sfx_vol <= 0.01:
			sfx_player.volume_db = -80.0
		else:
			sfx_player.volume_db = linear_to_db(sfx_vol)
	
	if bgm_player:
		if music_vol <= 0.01:
			bgm_player.volume_db = -80.0
		else:
			bgm_player.volume_db = linear_to_db(music_vol)

func play_sfx(sfx_name: String) -> void:
	if not streams.has(sfx_name):
		return
	if SaveSystem and SaveSystem.settings:
		var sfx_vol = float(SaveSystem.settings.get("sfx_volume", 0.8))
		if sfx_vol <= 0.01:
			return
	update_volumes()
	sfx_player.stream = streams[sfx_name]
	sfx_player.play()

func play_click() -> void:
	play_sfx("click")

func play_cash() -> void:
	play_sfx("cash")

func play_success() -> void:
	play_sfx("success")

func play_fail() -> void:
	play_sfx("fail")

func play_event() -> void:
	play_sfx("event")

func play_bgm() -> void:
	if not streams.has("bgm") or bgm_player.playing:
		return
	update_volumes()
	bgm_player.stream = streams["bgm"]
	bgm_player.play()

func stop_bgm() -> void:
	if bgm_player:
		bgm_player.stop()
