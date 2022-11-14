extends Node

# Global events
signal game_over
signal power_up_elevator_load_increase
signal power_up_floor_increase_capacity
signal power_up_reduce_stress_level
signal level_selected

# TODO implement
signal elevator_command_up_executed
signal elevator_command_down_executed

const screen_width = 1024
const screen_height = 600

var screenshot_texture: ImageTexture

# stage and level params
var overflown_floor = -1	# keeps track of the floor that caused a game over
var num_floors
var current_level = 0
var day_number = 1
var hour_of_day = 9
var current_level_day = 0
var passengers_delivered = 0

# user preferences (high scores, etc)
const FILE_NAME = "user://settings.cfg"
var config: ConfigFile
var seen_tutorial = false
var high_scores = [0, 0, 0, 0, 0, 0, 0]
var unlocked_levels = [true, false, false, false, false, false, false]
var prefs_music = true
var prefs_sound_effects = true

# power ups
var passenger_boarding_speed = 1
var elevator_speed = 1
var floors_expanded = false
var shaft_expanded = false
var floor_height = 50
var stress_timer = 30

# levels
var level1 = Level.new("New York", 1, 50, 4, false)
var level2 = Level.new("London", 2, 60, 5, false)
var level3 = Level.new("Rio", 3, 90, 5, false)
var level4 = Level.new("Berlin", 4, 100, 6, false)
var level5 = Level.new("Paris", 5, 150, 6, false)
var level6 = Level.new("Sydney", 6, 250, 7, false)
var level7 = Level.new("Beijing", 7, 300, 7, false)
var levels = [level1, level2, level3, level4, level5, level6, level7]

func _input(_ev):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func reset():
	passengers_delivered = 0

# get game to initial conditions
func reset_all():
	passenger_boarding_speed = 1
	elevator_speed = 1
	stress_timer = 30
	passengers_delivered = 0
	day_number = 1
	hour_of_day = 9
	current_level_day = 0
	current_level = 0
	overflown_floor = -1
	floors_expanded = false
	shaft_expanded = false

func get_current_level():
	return levels[current_level]
	
func load_user_prefs():
	config = ConfigFile.new()
	var err = config.load(FILE_NAME)
	if err == OK:
		seen_tutorial = config.get_value("prefs", "tutorial", false)
		
		# max score per level settings
		var max_score_level_0 = config.get_value("score", "level_0", 0)
		var max_score_level_1 = config.get_value("score", "level_1", 0)
		var max_score_level_2 = config.get_value("score", "level_2", 0)
		var max_score_level_3 = config.get_value("score", "level_3", 0)
		var max_score_level_4 = config.get_value("score", "level_4", 0)
		var max_score_level_5 = config.get_value("score", "level_5", 0)
		var max_score_level_6 = config.get_value("score", "level_6", 0)
		high_scores.clear()
		high_scores.push_back(max_score_level_0)
		high_scores.push_back(max_score_level_1)
		high_scores.push_back(max_score_level_2)
		high_scores.push_back(max_score_level_3)
		high_scores.push_back(max_score_level_4)
		high_scores.push_back(max_score_level_5)
		high_scores.push_back(max_score_level_6)
		
		# determine which levels are unlocked
		for i in range(1, levels.size()):
			var level = levels[i]
			var previous_level = levels[i-1]
			var score_previous_level = high_scores[i-1]
			var unlocked = score_previous_level >= previous_level.goal
			level.unlocked = unlocked
			unlocked_levels[i] = unlocked
			
		# music settings
		prefs_music = config.get_value("prefs", "prefs_music", true)
		prefs_sound_effects = config.get_value("prefs", "prefs_sound_effects", true)
	else:
		# file probably does not exist, write something to it
		config.set_value("dummy", "dummy", 1)
		config.save(FILE_NAME)

# returns the score if it is the user's highest, -1 otherwise
func save_score(level, score):
	load_user_prefs() # refresh
	var previous_score = high_scores[level]
	if score > previous_score:
		# save in memory
		high_scores[level] = score
		
		# save to file
		config.set_value("score", "level_" + str(level), score)
		config.save(FILE_NAME)
		return score
	
	return -1
	
func set_prefs_music(value):
	if !config:
		load_user_prefs()

	prefs_music = value
	config.set_value("prefs", "prefs_music", value)
	config.save(FILE_NAME)
	
func set_prefs_sound_effects(value):
	if !config:
		load_user_prefs()

	prefs_sound_effects = value
	config.set_value("prefs", "prefs_sound_effects", value)
	config.save(FILE_NAME)
