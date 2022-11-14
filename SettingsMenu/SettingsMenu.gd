extends Control

onready var center_container: CenterContainer = $CenterContainer
onready var music: CheckBox = $CenterContainer/VBoxContainer/Music
onready var sound_effects: CheckBox = $CenterContainer/VBoxContainer/SoundEffects
onready var scene_transition_enter = $SceneTransition
onready var scene_transition_exit = $SceneTransitionExit

func _ready():
	Global.load_user_prefs()
	
	scene_transition_enter.animate_in()
	
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	music.pressed = Global.prefs_music
	sound_effects.pressed = Global.prefs_sound_effects

func _on_viewport_size_changed():
	var width = OS.get_window_size().x
	var height = OS.get_window_size().y
	
	if width < Global.screen_width: return
	if height < Global.screen_height: return
	
	center_container.rect_size = Vector2(width, height)

func _on_Music_toggled(button_pressed: bool):
	Global.set_prefs_music(button_pressed)
	
	# stop music right away
	if button_pressed == false:
		Sound.stop_all()
	else:
		if !Sound.is_menu_music_playing(): Sound.play_menu_music()
	
func _on_SoundEffects_toggled(button_pressed: bool):
	Global.set_prefs_sound_effects(button_pressed)

func _on_BackButton_clicked() -> void:
	scene_transition_exit.animate("back")

func _on_SceneTransitionExit_complete(callback) -> void:
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
