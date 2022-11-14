extends Control

onready var scene_transition_enter = $SceneTransition
onready var scene_transition_exit = $SceneTransitionExit

func _ready():
	scene_transition_enter.animate_in()

func _on_BackButton_clicked() -> void:
	scene_transition_exit.animate("back")

func _on_SceneTransitionExit_complete(callback) -> void:
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
