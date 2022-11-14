extends Control

onready var scene_transition_enter = $SceneTransition
onready var scene_transition_exit = $SceneTransitionExit
onready var elevator: Elevator = $Elevator

func _ready():
	scene_transition_enter.animate_in()
	Global.load_user_prefs()
	
	setup_elevator_animation()
	
	if Global.prefs_music:
		Sound.play_menu_music()

func setup_elevator_animation():
	elevator.hide_destination()
	elevator.go_to_floor(5)
	elevator.connect("elevator_idle", self, "_elevator_idle")
	
func _elevator_idle():
	yield(get_tree().create_timer(2.0), "timeout")
	var next_floor = randi()%10
	elevator.go_to_floor(next_floor)
	
func _on_ExitButton_clicked() -> void:
	get_tree().quit()

func _on_SettingsButton_clicked() -> void:
	scene_transition_exit.animate("options")

func _on_PlayButton_clicked() -> void:
	scene_transition_exit.animate("play")

func _on_ControlsButton_clicked() -> void:
	scene_transition_exit.animate("tutorial")

func _on_SceneTransitionExit_complete(callback) -> void:
	match callback:
		"options":
			get_tree().change_scene("res://SettingsMenu/SettingsMenu.tscn")
		"play":
			get_tree().change_scene("res://LevelsMenu/LevelsMenu.tscn")
		"tutorial":
			get_tree().change_scene("res://TutorialMenu/TutorialMenu.tscn")



