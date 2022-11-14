extends Node2D

onready var hud = $HUD
onready var next_level = $NextLevelCanvas
onready var progress_timer: Timer = $ProgressTimer
onready var spawn_timer: Timer = $SpawnTimer
onready var floor_spawn_timer: Timer = $FloorSpawnTimer
onready var camera: Camera2D = $Camera
onready var building: Building
onready var elevator: Elevator

var next_level_dialog
var game_over_dialog
var game_paused_dialog
var nextLevelObject = preload("res://NextLevel/NextLevel.tscn")
var gameOverObject = preload("res://GameOverMenu/GameOverMenu.tscn")
var gamePausedObject = preload("res://GamePausedMenu/GamePausedMenu.tscn")

var next_floor = 0
var hour_of_day = 9

var prefs_play_music = true
var prefs_play_sfx = true

# reset node references after we replace an old level with a new one
func reset_nodes():
	building = get_node("Camera/Level/Building")
	elevator = get_node("Camera/Level/Building/Elevator")

func _ready():
	
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	
	# load initial level
	var level = Global.get_current_level()
	load_level(level)
	
	prefs_play_music = Global.prefs_music
	prefs_play_sfx = Global.prefs_sound_effects
	
	# update hud
	hud.set_day(Global.current_level_day + 1)
	hud.set_level(Global.get_current_level().name)
	building.connect("passenger_delivered", hud, "_on_Passenger_delivered")
	building.connect("passenger_delivered", self, "_on_Passenger_delivered")
	
	# listen to global event bus
	Global.connect("game_over", self, "_on_game_over")
	Global.connect("power_up_elevator_load_increase", self, "_on_power_up_elevator_load_increase")
	Global.connect("power_up_floor_increase_capacity", self, "_on_power_up_floor_increase_capacity")
	Global.connect("power_up_reduce_stress_level", self, "_on_power_up_reduce_stress_level")
	
	_on_viewport_size_changed()
	
	if prefs_play_music:
		Sound.play_in_game_music()

	# manually so it's placed on top of building, passengers, levels, etc
	var scene_transition = load("res://SceneTransition/SceneTransition.tscn").instance()
	add_child(scene_transition)
	scene_transition.rect_size.x = Global.screen_width
	scene_transition.rect_size.y = Global.screen_height
	scene_transition.animate_in()

func _on_Passenger_delivered():
	if prefs_play_sfx:
		Sound.play_in_game_sfx()

func _on_viewport_size_changed():
	var width = OS.get_window_size().x
	var height = OS.get_window_size().y
	
	if width < Global.screen_width: return
	if height < Global.screen_height: return
	
	#camera.offset.x = -abs((Global.screen_width - width)/2)
	#camera.offset.y = -abs((Global.screen_height - height)/2)

func load_level(level: Level):
	
	# load level UI
	var s = "res://Levels/Level" + str(level.number) + "/Level" + str(level.number) + ".tscn"
	var new_level_scene = load(s)
	var new_level = new_level_scene.instance()
	
	# reset nodes
	camera.remove_child(get_node("Level"))
	camera.add_child(new_level)
	reset_nodes()
	
	# create initial number of floors
	building.add_floors(level.num_floors)
	
	hud.start_clock()
	Stats.start_timer = OS.get_ticks_msec()

func _input(_ev):
	if Input.is_key_pressed(KEY_UP):
		next_floor += 1
		next_floor = clamp(next_floor, 0, Global.num_floors-1)
		elevator.set_next_floor_label(next_floor)
		building.set_next_floor_intent(next_floor)
	elif Input.is_key_pressed(KEY_DOWN):
		next_floor -= 1
		next_floor = clamp(next_floor, 0, Global.num_floors-1)
		elevator.set_next_floor_label(next_floor)
		building.set_next_floor_intent(next_floor)
	elif Input.is_key_pressed(KEY_SPACE):
		if building.all_passengers_processed():
			elevator.go_to_floor(next_floor)
	elif Input.is_key_pressed(KEY_ESCAPE):  
		get_tree().paused = true
		game_paused_dialog = gamePausedObject.instance()
		game_paused_dialog.visible = true
		game_paused_dialog.connect("resume_game", self, "_on_GamePausedMenu_resume_game")
		add_child(game_paused_dialog)
			
		building.send_passengers_to_back()

func advance_stage():
	next_level_dialog = nextLevelObject.instance()
	next_level_dialog.connect("continue_clicked", self, "_on_Advance_Stage_Continue_clicked")
	add_child(next_level_dialog)

func _on_power_up_elevator_load_increase():
	building.expand_elevator_load()

func _on_power_up_floor_increase_capacity():
	building.expand_floors()
	
func _on_power_up_reduce_stress_level():
	Global.stress_timer = 40

# resumes game play after a user advances game stage
func _on_Advance_Stage_Continue_clicked():
	remove_child(next_level_dialog)
	get_tree().paused = false
	hud.start_clock()

# handle user clicking "next level"
func _on_NextLevel_clicked():
	Global.reset()
	
	# load next level
	var level = Global.get_current_level()
	load_level(level)
	
	get_tree().reload_current_scene()

# controls the random spawning of passengers
func _on_SpawnTimer_timeout():
	building.spawn_passenger()
	spawn_timer.start((randi() % 2) + 1)

# controls the spawning of new floors
func _on_FloorSpawnTimer_timeout():
	if building.num_floors < 8:
		building.spawn_floor()
		#floor_spawn_timer.start(30)
		floor_spawn_timer.start((randi() % 30) + 60)

# control the main timer (day progress)
func _on_ProgressTimer_timeout():
	
	if Global.hour_of_day == 17:
		# advance stage
		Global.current_level_day += 1
		Global.hour_of_day = 9
		hud.set_hour(Global.hour_of_day)
		hud.set_day(Global.current_level_day + 1)
		
		# show dialog
		get_tree().paused = true
		advance_stage()
	else:
		Global.hour_of_day = Global.hour_of_day + 1
		hud.set_hour(Global.hour_of_day)

func _on_GamePausedMenu_resume_game() -> void:
	remove_child(game_paused_dialog)
	get_tree().paused = false
	building.bring_passengers_to_front()

# reacts to event emmitted by a Floor
func _on_game_over():
	
	take_screenshot()
	
	var score = Global.passengers_delivered
	Global.save_score(Global.current_level, score)
	Stats.set_end_timer(OS.get_ticks_msec())
	
	get_tree().paused = true
	game_over_dialog = gameOverObject.instance()
	add_child(game_over_dialog)
	
func take_screenshot():
	get_viewport_rect()
	var capture = building.get_viewport().get_texture().get_data()
	capture.flip_y()
	#yield(get_tree(), "idle_frame")
	#yield(get_tree(), "idle_frame")
	
	# scale
	var s = capture.get_size()
	var scale_reduce = 0.4
	capture.resize(s.x * scale_reduce, s.y * scale_reduce)

	# crop
	#var border = building
	#var border_s = building.to_global(border.texture.get_size())
	#var border_p = building.to_global(border.position)
	#var zone = Rect2(Vector2(0,0), border_s * scale_reduce)
	
	# copy to a new image, I need to create it first with the same size with create()
	#var imgDest = Image.new()
	#imgDest.create(zone.size.x, zone.size.y, false, capture.get_format())
	#imgDest.blit_rect(capture, zone, Vector2.ZERO)

	# Create a texture for it.
	Global.screenshot_texture = ImageTexture.new()
	Global.screenshot_texture.create_from_image(capture)
	
	# make texture
	#Global.screenshot_texture = ImageTexture.new()
	#Global.screenshot_texture.create_from_image(capture)
