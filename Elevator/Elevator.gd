extends Node2D

class_name Elevator

signal elevator_idle

onready var tween = $Tween
onready var sprite = $Sprite

# slots to place passengers
onready var A = $A
onready var B = $B
onready var C = $C
onready var D = $D
onready var destination = $Destination

enum STATE { IDLE, BOARDING, MOVING }

const height_offset = 0

var elevator_size = 0 # can be 0, 1 or 2
var initial_position_y
var state = STATE.IDLE
var current_floor = 0
var next_floor = -1
var positions = []
var reserved_positions = [null, null, null, null]
var passengers = []
var max_passengers = 4
var num_passengers = 0

func reset():

	# clear UI
	for x in range(positions.size()):
		var parent = positions[x]
		var p = parent.get_child(0)
		parent.remove_child(p)
	
	initial_position_y = position.y
	positions.clear()
	positions = [A, B, C, D]
	reserved_positions.clear()
	reserved_positions = [null, null, null, null]
	passengers.clear()
	num_passengers = 0

func _ready():
	initial_position_y = position.y
	positions = [A, B, C, D]
	
func set_next_floor_label(number):
	destination.text = str(number)

func go_to_floor(number):
	
	if state != STATE.IDLE:
		print('Elevator not idle - ignoring commands')
		return
	
	state = STATE.MOVING
	next_floor = number
	
	# animate between current and next floor
	var tween_duration = abs(current_floor - next_floor) * Global.elevator_speed
	var end = initial_position_y - number*Global.floor_height - number*height_offset
	tween.interpolate_property(self, "position", position, Vector2(position.x, end), tween_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

# called when the elevator animation tween ends 
func _on_Tween_all_completed():
	state = STATE.IDLE
	var num_floors_travelled = abs(next_floor - current_floor)
	current_floor = next_floor
	next_floor = -1
	Stats.add_floors_travelled(num_floors_travelled)
	emit_signal("elevator_idle")

# reserve a place for a passenger, return its final position
func reserve_space(passenger):
	for i in range(reserved_positions.size()):
		var reserved = reserved_positions[i]
		if reserved == null:
			reserved_positions[i] = passenger
			num_passengers += 1
			return positions[i].position.x

func fully_occupied(): return num_passengers == max_passengers

# register a passenger to this elevator, returns -1 if no more space
func register_passenger(passenger):
	
	# make sure this passenger stops shaking once they're boarded
	passenger.stop_shaking()
	
	# find reserved position
	var position_index = -1
	for i in range(reserved_positions.size()):
		if reserved_positions[i] == passenger:
			position_index = i
	
	if(position_index != -1):
		passenger.position = Vector2(0, 0)
		passengers.push_back(passenger)
		
		var node_position = positions[position_index]
		node_position.add_child(passenger)
	else:
		return -1

func unregister_passenger(passenger):
	# remove from reserved position
	for i in range(reserved_positions.size()):
		if reserved_positions[i] == passenger:
			reserved_positions[i] = null
			num_passengers -= 1

	# remove from tree
	for x in range(positions.size()):
		var parent = positions[x]
		var p = parent.get_child(0)
		if passenger == p:
			passengers.remove(passengers.find(passenger))
			parent.remove_child(p)

# returns an available position for a new passenger
func get_available_position_for_passenger():
	for x in range(positions.size()):
		var pos = positions[x]
		if(pos.get_child_count() == 0):
			return pos
	return null
	
func expand():
	
	if elevator_size == 0:
		elevator_size = 1
		max_passengers = 6
	elif elevator_size == 1:
		elevator_size = 2
		max_passengers = 8
	else:
		return
		
	sprite.rect_position.x -= 20
	sprite.rect_size.x += 40
		
	# create 2 new nodes
	var e = Node2D.new()
	e.position.x = D.position.x + 13
	e.position.y = 15
	add_child(e)
	
	var f = Node2D.new()
	f.position.x = A.position.x - 13
	f.position.y = 15
	add_child(f)
	
	# final setup: [F, A, B, C, D, E]
	positions.push_front(f)
	positions.push_back(e)
	reserved_positions.push_front(null)
	reserved_positions.push_back(null)
	
func hide_destination(): destination.visible = false

func has_space_available(): return num_passengers < max_passengers

func get_size(): return sprite.texture.get_size()

func get_passengers(): return passengers
