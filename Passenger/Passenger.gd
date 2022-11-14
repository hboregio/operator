extends Node2D

onready var tween_entering: Tween = $EnteringTween
onready var tween_exiting: Tween = $ExitingTween
onready var tween_sliding: Tween = $SlidingTween
onready var sprite = $Sprite
onready var label = $Label
onready var player = $AnimationPlayer

signal elevator_boarded(passenger)
signal elevator_exited(passenger)

enum STATE { WAITING, BOARDING, ONBOARD, SLIDING, EXITING, EXITED }

var state
var current_floor
var desired_floor

var shake: bool = false
var max_offset = Vector2(8, 8)
var trauma = 1.0
var shake_stepper = 0

# stats
var timestamp_in
var timestamp_out

func _ready():
	state = STATE.WAITING
	player.play("AppearIn")
	timestamp_in = OS.get_ticks_msec()

func _process(delta):
	if shake:
		if shake_stepper > 8:
			shake_stepper = 0
			shake(delta)
		else:
			shake_stepper += 1
	
func shake(delta):
	sprite.offset.x = delta * max_offset.x * trauma * rand_range(-5, 5)
	sprite.offset.y = delta * max_offset.y * trauma * rand_range(-5, 5)

func setup(origin, destination):
	state = STATE.WAITING
	self.current_floor = origin
	self.desired_floor = destination
	label.text = str(destination)
	sprite.texture = load("res://assets/passenger" + str(randi()%5) + ".png")

func board_elevator(end_position_x):
	state = STATE.BOARDING
	
	var tween_duration = abs(position.x - end_position_x)/60 * Global.passenger_boarding_speed
	tween_entering.interpolate_property(self, "position", position, Vector2(end_position_x, position.y), tween_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween_entering.start()
	
func exit_elevator():
	state = STATE.EXITING
	tween_exiting.interpolate_property(self, "position", position, Vector2(100, position.y), Global.passenger_boarding_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween_exiting.start()

func slide_to(position_x):
	state = STATE.SLIDING
	
	var tween_duration = abs(position.x - position_x)/60 * Global.passenger_boarding_speed
	tween_sliding.interpolate_property(self, "position", position, Vector2(position_x, position.y), tween_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween_sliding.start()

func get_size(): return sprite.texture.get_size()

# called when the passenger has entered the elevator
func _on_EnteringTween_tween_completed(object, key):
	state = STATE.ONBOARD
	emit_signal("elevator_boarded", self)

# called when the passenger has exited the elevator
func _on_ExitingTween_tween_completed(object, key):
	state = STATE.EXITED
	player.play("FadeOut")

# called when the fade out animation is complete
func clear_passenger():
	emit_signal("elevator_exited", self)
	timestamp_out = OS.get_ticks_msec()
	var diff = (timestamp_out - timestamp_in) / 1000
	Stats.add_waiting_time(diff)
	queue_free()

func start_shaking():
	shake = true

func stop_shaking():
	shake = false
	sprite.offset = Vector2(0,0)

func _on_SlidingTween_tween_completed(object: Object, key: NodePath) -> void:
	state = STATE.WAITING
