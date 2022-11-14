extends Node2D

onready var floor_indicator = $FloorIndicator
onready var background: NinePatchRect = $Block/Background
onready var shaft: NinePatchRect = $Block/Shaft
onready var group = $Group
onready var label = $Group/Label
onready var player = $AnimationPlayer
onready var progress_timer: Timer = $ProgressTimer
onready var progress = $Group/Progress
onready var progress_animator = $Group/Progress/AnimationPlayer
onready var roof_top = $Roof

var floor_size = 0 # can be 0, 1 or 2
var floor_number
var floor_width = 200
var floor_height = 50
var max_passengers = 4
var animate_entry = false
var queue = []

func _ready():

	# initialize all positions to null
	for i in range(0, max_passengers):
		queue.push_front(null)

	if animate_entry:
		player.play("AppearIn")

func _process(_delta):
	if get_passengers_waiting().size() >= max_passengers:
		if progress_timer.get_time_left() == 0:
			progress.visible = true
			progress_animator.play("AppearIn")
			progress_timer.start()
			
			shake_passengers()
		else:
			var percentage = (Global.stress_timer - progress_timer.time_left)*100/Global.stress_timer
			progress.value = int(percentage)
	elif progress.visible:
		progress.value = 0
		progress_animator.play("DisappearOut")
		progress_timer.stop()
		
		unshake_passengers()

func set_floor_number(number):
	self.floor_number = number
	label.text = str(number)

func register_passenger(passenger):
	var idx = -1
	var position_x = -1
	for i in range(0, queue.size()):
		if queue[i] == null:
			idx = i
			position_x = 60 + (i) * 30
			break

	passenger.position = Vector2(-position_x, 15)
	queue[idx] = passenger
	add_child(passenger)

# called when a passenger leaves a floor and boards an elevator
func unregister_passenger(passenger):
	var pos = queue.find(passenger)
	queue[pos] = null
	remove_child(passenger)
	
	# TODO re-arrange passengers in this floor
	# TODO animate their sliding
	var new_queue = []
	for i in range(0, queue.size()):
		if queue[i] != null:
			new_queue.push_back(queue[i])
	
	# re-fill new queue with empty elements at the end
	var diff = queue.size() - new_queue.size()
	for i in range(0, diff):
		new_queue.push_back(null)
	
	# re-assign queue to new queue
	queue = new_queue
	
	# TODO slide passengers closer to the elevator
	var position_x = -1
	for i in range(0, new_queue.size()):
		if new_queue[i] != null:
			position_x = 60 + (i) * 30
			#new_queue[i].position = Vector2(-position_x, 15)
			if new_queue[i].state == new_queue[i].STATE.WAITING: 
				new_queue[i].slide_to(-position_x)

func get_size():
	return floor_indicator.texture.get_size()

# TODO not efficient - create secondary data structure for it instead
func get_passengers_waiting():
	var new_queue = []
	for i in range(0, queue.size()):
		if queue[i] != null:
			new_queue.push_back(queue[i])
	return new_queue

func is_floor_full():
	return get_passengers_waiting().size() >= max_passengers

func expand(expand_shaft = false):
	
	# for now, only this is active
	if floor_size == 0:
		floor_size = 1
	
		# expand floor background
		background.rect_position.x = -300
		background.rect_size.x = 600
		group.position.x -= 100
		max_passengers = 7
		
		# expand roof-top as well
		if roof_top.visible:
			roof_top.rect_position.x = -300
			roof_top.rect_size.x = 600
		
		# expand shaft
		if expand_shaft:
			expand_shaft()
	
	elif floor_size == 1:
		floor_size = 2

		# expand floor background
		background.rect_position.x = -400
		background.rect_size.x = 800
		group.position.x -= 100
		max_passengers = 9
		
		# expand shaft
		if expand_shaft:
			expand_shaft()
	
	elif floor_size >= 2:
		return

	queue.resize(max_passengers)
	
	# if size increases, passengers no longer shake
	unshake_passengers()
	
func expand_shaft():
	if floor_size == 1:
		shaft.rect_position.x -= 20
		shaft.rect_size.x += 40
	elif floor_size == 2:
		shaft.rect_position.x -= 20
		shaft.rect_size.x += 40

func show_roof_top():
	roof_top.visible = true

func hide_roof_top():
	roof_top.visible = false
	
func shake_passengers():
	for p in queue:
		if p != null:
			p.start_shaking()

func unshake_passengers():
	for p in queue:
		if p != null:
			p.stop_shaking()

func _on_ProgressTimer_timeout():
	Global.overflown_floor = floor_number
	Global.emit_signal("game_over")

func _on_Progress_animation_finished(anim_name: String) -> void:
	if anim_name == "DisappearOut":
		progress.visible = false
