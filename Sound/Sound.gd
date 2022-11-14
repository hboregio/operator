extends Node

onready var in_game_music: AudioStreamPlayer = $InGameMusicPlayer
onready var in_game_sfx: AudioStreamPlayer = $InGameFXPlayer
onready var menu_music: AudioStreamPlayer = $MenuMusicPlayer

onready var game_starting_tween: Tween = $GameStartingAudioTween
onready var menu_starting_tween: Tween = $MenuStartingAudioTween

func stop_all():
	in_game_music.stop()
	in_game_sfx.stop()
	menu_music.stop()
	
func play_in_game_music():
	# fade-out menu music
	game_starting_tween.interpolate_property(menu_music, "volume_db", 0, -80, 2.5, Tween.TRANS_SINE, Tween.EASE_IN, 0)
	game_starting_tween.start()
	
	# start right away to give it a blending effect
	in_game_music.play()
	
func play_in_game_sfx():
	in_game_sfx.play()

func play_menu_music():
	in_game_music.stop()
	
	# fade in
	if !menu_music.playing:
		# fade-in menu music
		menu_music.play()
		menu_starting_tween.interpolate_property(menu_music, "volume_db", -80, 0, 1.5, Tween.TRANS_SINE, Tween.EASE_IN, 0)
		menu_starting_tween.start()

func is_menu_music_playing():
	return menu_music.playing

func _on_GameStartingAudioTween_tween_all_completed() -> void:
	menu_music.stop()

func _on_MenuStartingAudioTween_tween_all_completed() -> void:
	pass # Replace with function body.
