extends Control

onready var level = $Level
onready var delivered = $DeliveredLabel
onready var day = $Day
onready var player = $AnimationPlayer
onready var time_label = $TimeLabel
onready var clock = $Clock
onready var paused_button: Button = $PauseButton
onready var paused_label = $PausedLabel
onready var paused_label_player = $PausedLabelAnimation

func set_level(name): level.text = name
	
func set_delivered(number):
	player.play("AnimateDelivered")
	delivered.text = str(number)

func set_day(d):
	day.text = "Day " + str(d)

func set_hour(hour):
	player.play("AnimateTimeLabel")
	if hour < 12:
		time_label.text = str(hour) + " am"
	else:
		var dif = hour - 12
		if dif == 0:
			dif = 12
		time_label.text = str(dif) + " pm"

func start_clock():
	clock.start()

func stop_clock():
	clock.stop()
	
func _on_Passenger_delivered():
	set_delivered(Global.passengers_delivered)

func _on_PauseButton_clicked() -> void:
	
	if get_tree().paused:
		paused_button.icon = load("res://assets/pause.png")
		paused_label_player.play("Disappear")
	else:
		paused_button.icon = load("res://assets/play.png")
		paused_label.visible = true
		paused_label_player.play("Appear")

func _on_PausedLabelAnimation_animation_finished(anim_name: String) -> void:
	if anim_name == "Disappear":
		paused_label.visible = false
	
	get_tree().paused = not get_tree().paused
