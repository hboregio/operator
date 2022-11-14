extends Node

# aggregate stats
var start_timer
var total_floors_travelled = 0
var total_waiting_time = 0
var total_elevator_moves = 0

# calculated stats
var avg_waiting_time: float = 0.0
var played_time = 0

func reset():
	total_floors_travelled = 0
	total_waiting_time = 0
	total_elevator_moves = 0
	avg_waiting_time = 0.0
	
func set_end_timer(end_time):
	played_time = (end_time - start_timer) / 1000

# updated when a paseenger is delivered
func add_waiting_time(time):
	total_waiting_time += time
	avg_waiting_time = total_waiting_time / Global.passengers_delivered

func add_floors_travelled(value):
	total_floors_travelled += value
