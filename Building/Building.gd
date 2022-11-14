extends Node2D

class_name Building

signal passenger_delivered

onready var floors_node = $Floors
onready var elevator = $Elevator

var passengers = []
var floors = []
var num_floors = 0
var next_floor_intent = 0
var floorObject = preload("res://Floor/Floor.tscn")
var passengerObject = preload("res://Passenger/Passenger.tscn")

func _ready():
	set_process(true)
	elevator.current_floor = 0

func _process(_delta):
	update()
	if elevator.state == elevator.STATE.IDLE:
		process_in_transit_passengers()

func _draw():
	# draw elevator line from top (25 is the floor's height/2)
	var end_y = floors[floors.size()-1].position.y - 25
	draw_line(elevator.position, Vector2(0, end_y), Color(0.19, 0.19, 0.19), 2)
	
	var end_y2 = floors[next_floor_intent].position.y
	draw_line(elevator.position, Vector2(0, end_y2), Color(0.19, 0.19, 0.19), 4)
	draw_circle_arc_poly(Vector2(0, end_y2), 4, 0, 360, Color(0.19, 0.19, 0.19))

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func set_next_floor_intent(floor_number):
	next_floor_intent = floor_number
	
func process_in_transit_passengers():
	# get passengers out
	var elevator_passengers = elevator.get_passengers()
	for p in elevator_passengers:
		if p.state == p.STATE.ONBOARD && elevator.current_floor == p.desired_floor:
			p.exit_elevator()
	
	# get passengers in
	var queue = floors[elevator.current_floor].get_passengers_waiting()
	for p in queue:
		if p.state == p.STATE.WAITING:
			if elevator.has_space_available():
				var end_position = elevator.reserve_space(p)
				p.board_elevator(end_position)

func spawn_floor():
	var last_floor = floors[floors.size() - 1]
	last_floor.hide_roof_top()
	add_floor(true, true)

func add_floor(animate_entry, show_roof_top):
	var a_floor = floorObject.instance()
	a_floor.animate_entry = animate_entry
	floors_node.add_child(a_floor)
	if Global.floors_expanded: a_floor.expand()
	if Global.shaft_expanded: a_floor.expand_shaft()
	if show_roof_top: a_floor.show_roof_top()
	
	# add floor
	a_floor.set_floor_number(num_floors)
	a_floor.position = Vector2(0, -Global.floor_height*num_floors)
	floors.push_back(a_floor)

	num_floors += 1
	
	Global.num_floors = num_floors

func add_floors(quantity):
	for i in range(0, quantity):
		add_floor(false, i == quantity-1)

func expand_elevator_load():
	Global.shaft_expanded = true
	elevator.expand()
	for f in floors:
		f.expand_shaft()

func expand_floors():
	Global.floors_expanded = true
	for f in floors:
		f.expand()

func spawn_passenger():

	randomize()
	
	# generate random origin/destination
	var origin = randi()%num_floors
	var destination = randi()%num_floors
	while destination == origin:
		destination = randi()%num_floors

	# check if we can spawn this passenger (skips spawning if full)
	# this creates the "handicap" effect of backing off spawning if floors are getting full,
	# to give users a better shot of catching up
	if floors[origin].is_floor_full():
		return

	# register passenger
	var p = passengerObject.instance()
	p.z_index = 1
	floors[origin].register_passenger(p)
	
	# register callbacks on main
	p.connect("elevator_boarded", self, "_on_Passenger_elevator_boarded")
	p.connect("elevator_exited", self, "_on_Passenger_elevator_exited")
	p.setup(origin, destination)

	# keep a reference to the passenger
	passengers.push_back(p)

func all_passengers_processed():
	for p in passengers:
		if p.state == p.STATE.BOARDING or p.state == p.STATE.EXITING:
			return false
	return true

func _on_Passenger_elevator_boarded(p):
	floors[p.current_floor].unregister_passenger(p)
	elevator.register_passenger(p)

func _on_Passenger_elevator_exited(p):
	passengers.remove(passengers.find(p))
	p.queue_free()
	elevator.unregister_passenger(p)
	Global.passengers_delivered += 1
	emit_signal("passenger_delivered")

# dirty trick to work around control nodes not having z-order
func bring_passengers_to_front():
	for p in passengers:
		p.z_index = 1

func send_passengers_to_back():
	for p in passengers:
		p.z_index = 0
