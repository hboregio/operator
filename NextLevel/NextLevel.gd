extends CanvasLayer

signal continue_clicked

onready var power_up_title = $Left/PowerUpTitle
onready var power_up_description = $Left/PowerUpDescription
onready var power_up_sprite = $Left/PowerUpSprite

onready var power_up_title2 = $Right/PowerUpTitle
onready var power_up_description2 = $Right/PowerUpDescription
onready var power_up_sprite2 = $Right/PowerUpSprite

onready var title = $Title

var passenger_speed = load("res://assets/passenger_speed.png")
var elevator_speed = load("res://assets/elevator_speed.png")
var elevator_box = load("res://assets/box.png")
var stress = load("res://assets/stress.png")
var expand = load("res://assets/expand.png")

func _ready():
	title.text = "Day " + str(Global.current_level_day)
	
	match Global.current_level_day:
		1:
			# left
			power_up_sprite.icon = passenger_speed
			power_up_title.text = "Boarding Speed"
			power_up_description.text = "Passengers will enter and exit the elevator 15% faster"
			
			# right
			power_up_sprite2.icon = elevator_speed
			power_up_title2.text = "Elevator Speed"
			power_up_description2.text = "Elevator will travel 10% faster"
		2:
			# left
			power_up_sprite.icon = elevator_speed
			power_up_title.text = "Elevator Speed"
			power_up_description.text = "Elevator will travel 10% faster"
			
			# right
			power_up_sprite2.icon = expand
			power_up_title2.text = "Floor Capacity"
			power_up_description2.text = "Each floor will hold an extra 4 passengers"
		3:
			# left
			power_up_sprite.icon = elevator_box
			power_up_title.text = "Elevator Load"
			power_up_description.text = "Elevator will carry 2 extra passengers"
			
			# right
			power_up_sprite2.icon = elevator_box
			power_up_title2.text = "Boarding Speed"
			power_up_description2.text = "Passengers will enter and exit the elevator 15% faster"
		4:
			# left
			power_up_sprite.icon = stress
			power_up_title.text = "Stress Levels"
			power_up_description.text = "Passengers will take longer to stress out when the floor is full"
			
			# right
			power_up_sprite2.icon = elevator_speed
			power_up_title2.text = "Elevator Speed"
			power_up_description2.text = "Elevator will travel 15% faster"
		_:
			# left
			if !Global.floors_expanded:
				power_up_sprite.icon = expand
				power_up_title.text = "Floor Capacity"
				power_up_description.text = "Each floor will hold an extra 4 passengers"
			else :
				power_up_sprite.icon = elevator_speed
				power_up_title.text = "Elevator Speed"
				power_up_description.text = "Elevator will travel 15% faster"
				
			# right
			if !Global.shaft_expanded:
				power_up_sprite2.icon = elevator_box
				power_up_title2.text = "Elevator Capacity"
				power_up_description2.text = "Elevator can carry 2 extra passengers"
			else:
				power_up_sprite2.icon = elevator_box
				power_up_title2.text = "Boarding Speed"
				power_up_description2.text = "Passengers will enter and exit the elevator 15% faster"

func _on_right_clicked() -> void:
	process_power_up("right")

func _on_Left_clicked() -> void:
	process_power_up("left")

func process_power_up(which_one):
	
	match Global.current_level_day:
		1:
			if which_one == "left":
				Global.passenger_boarding_speed = Global.passenger_boarding_speed * 0.85
			elif which_one == "right":
				Global.elevator_speed = Global.elevator_speed * 0.9
		2:
			if which_one == "left":
				Global.elevator_speed = Global.elevator_speed * 0.9
			elif which_one == "right":
				Global.emit_signal("power_up_floor_increase_capacity")
		3:
			if which_one == "left":
				Global.emit_signal("power_up_elevator_load_increase")
			elif which_one == "right":
				Global.passenger_boarding_speed = Global.passenger_boarding_speed * 0.85
		4:
			if which_one == "left":
				Global.emit_signal("power_up_reduce_stress_level")
			elif which_one == "right":
				Global.elevator_speed = Global.elevator_speed * 0.9
		_:
			if which_one == "left":
				if !Global.floors_expanded:
					Global.emit_signal("power_up_floor_increase_capacity")
				else:
					Global.elevator_speed = Global.elevator_speed * 0.9
			elif which_one == "right":
				if !Global.shaft_expanded:
					Global.emit_signal("power_up_elevator_load_increase")
				else:
					Global.passenger_boarding_speed = Global.passenger_boarding_speed * 0.85
			
	
	emit_signal("continue_clicked")
