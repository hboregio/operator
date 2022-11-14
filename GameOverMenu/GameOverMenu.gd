extends CanvasLayer

onready var reason: Label = $Reason
onready var score: Label = $Score
onready var screenshot: Sprite = $Screenshot
onready var days_played = $DaysPlayed
onready var time_played = $TimePlayed
onready var floors_travelled = $FloorsTravelled
onready var wait_time = $WaitTime

var current_level

func _ready():
	reason.text = "Too many passengers left waiting on floor #" + str(Global.overflown_floor)
	score.text = "You safely delivered " + str(Global.passengers_delivered) + " passengers."
	
	# set summary / stats
	screenshot.set_texture(Global.screenshot_texture)
	days_played.text = str(Global.current_level_day)
	time_played.text = str(Stats.played_time) + " seconds"
	floors_travelled.text = str(Stats.total_floors_travelled)
	wait_time.text = str(Stats.avg_waiting_time) + " seconds"
	
	# keep track of level in case player picks "play again"
	current_level = Global.current_level
	
	Global.reset_all()

func _on_RetryButton_clicked() -> void:

	Global.current_level = current_level

	get_tree().paused = false
	get_tree().change_scene("res://Main.tscn")
	
	Sound.stop_all()

func _on_BackButton_clicked() -> void:
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
	
	Sound.stop_all()
