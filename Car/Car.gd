extends Node2D

onready var screen_size = get_viewport_rect().size
onready var player = $AnimationPlayer
onready var sprite = $Passenger
onready var tween_appear = $Tween

enum DIRECTION { NORTH, SOUTH, EAST, WEST }

export(DIRECTION) var direction = DIRECTION.NORTH

func _ready():
	spawn()
	
func spawn():
	
	# wait some time before spawning
	randomize()
	yield(get_tree().create_timer(randi()%5), "timeout")
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	
	# randomize sprite
	randomize()
	var r = randi()%5
	sprite.texture = load("res://assets/passenger" + str(r) + ".png")
	
	var speed = randi()%6+6
	var start_x
	var end_x
	var start_y
	var end_y
	
	# pick random place to spawn
	if direction == DIRECTION.EAST:
		start_x = randi()%int(screen_size.x + 100)
		end_x = start_x + 100
		start_y = randi()%int(screen_size.y) + 100
		end_y = start_y
	elif direction == DIRECTION.WEST:
		start_x = randi()%int(screen_size.x + 100)
		end_x = start_x - 100
		start_y = randi()%int(screen_size.y) + 100
		end_y = start_y
	elif direction == DIRECTION.SOUTH:
		start_y = randi()%int(screen_size.y) + 100
		end_y = start_y + 100
		start_x = randi()%int(screen_size.x + 100)
		end_x = start_x
	else:
		start_y = randi()%int(screen_size.y) + 100
		end_y = start_y - 100
		start_x = randi()%int(screen_size.x + 100)
		end_x = start_x

	player.play("Appear")
	tween_appear.interpolate_property(self, "position", Vector2(start_x, start_y), Vector2(end_x, end_y), speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween_appear.start()

func die():
	player.play("Disappear")

func _on_Tween_all_completed() -> void:
	die()

func _on_AnimationPlayer_finished(anim_name: String) -> void:
	if anim_name == "Disappear":
		spawn()
		
func _on_viewport_size_changed():
	screen_size = OS.get_window_size()
