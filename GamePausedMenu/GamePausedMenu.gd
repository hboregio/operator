extends Control

signal resume_game

func _on_Resume_clicked():
	emit_signal("resume_game")

func _on_Exit_clicked():
	
	Global.reset_all()
	
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
	
	Sound.stop_all()
