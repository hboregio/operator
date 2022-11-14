tool
extends Control

onready var nyc = $ScrollContainer/HBoxContainer/NYC
onready var london = $ScrollContainer/HBoxContainer/London
onready var rio = $ScrollContainer/HBoxContainer/Rio
onready var berlin = $ScrollContainer/HBoxContainer/Berlin
onready var paris = $ScrollContainer/HBoxContainer/Paris
onready var sydney = $ScrollContainer/HBoxContainer/Sydney
onready var beijing = $ScrollContainer/HBoxContainer/Beijing

onready var scene_transition_enter = $SceneTransition
onready var scene_transition_exit = $SceneTransitionExit

var levels = Global.levels
var levels_ui = []

func _ready() -> void:
	Global.connect("level_selected", self, "_on_level_selected")
	scene_transition_enter.animate_in()
	
	levels_ui = [nyc, london, rio, berlin, paris, sydney, beijing]
	
	set_level_values()
	
func set_level_values():
	
	# load data (assumes elements are ordered correctly)
	Global.load_user_prefs()
	var high_scores = Global.high_scores
	var unlocked_levels = Global.unlocked_levels
	
	# set high score and unlocked status
	for i in range(levels.size()):
		
		var best = high_scores[i]
		var goal = levels[i].goal
		var enabled = unlocked_levels[i]
		
		if enabled:
			if best > goal:
				levels_ui[i].set_best("Best: " + str(best) + " passengers")
				levels_ui[i].set_enabled(enabled)
			else:
				levels_ui[i].set_best("Deliver " + str(goal) + " passengers to advance")
				levels_ui[i].set_enabled(enabled)
		else:
			levels_ui[i].set_best("Deliver " + str(levels[i-1].goal) + " passengers in " + levels[i-1].name + " to unlock")
			levels_ui[i].set_enabled(enabled)

func _on_level_selected(value):
	match value:
		"New York":
			Global.current_level = 0
		"London":
			Global.current_level = 1
		"Rio":
			Global.current_level = 2
		"Berlin":
			Global.current_level = 3
		"Paris":
			Global.current_level = 4
		"Sydney":
			Global.current_level = 5
		"Beijing":
			Global.current_level = 6
			
	get_tree().change_scene("res://Main.tscn")

func _on_Back_clicked() -> void:
	scene_transition_exit.animate("back")

func _on_SceneTransitionExit_complete(callback) -> void:
	match callback:
		"back":
			Global.current_level = 0
			get_tree().change_scene("res://MainMenu/MainMenu.tscn")
		_:
			get_tree().change_scene("res://Main.tscn")
