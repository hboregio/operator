class_name Level

var name: String
var number: int
var goal: int
var num_floors: int
var unlocked: bool

func _init(name, number, goal, num_floors, unlocked):
	self.name = name
	self.number = number
	self.goal = goal
	self.num_floors = num_floors
	self.unlocked = unlocked
