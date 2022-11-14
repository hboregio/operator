tool
extends VBoxContainer

onready var image: Button = $CenterContainer/Image
onready var description: Label = $Description
onready var best: Label = $Best

export(String) var cityName
export(String) var cityDescription
export(Texture) var cityIcon
export(String) var cityBest
export(bool) var enabled

func _ready() -> void:
	image.icon = cityIcon
	description.text = cityDescription
	best.text = cityBest
	image.disabled = not enabled
		
func set_best(value):
	best.text = value
	
func set_enabled(value):
	self.enabled = value
	image.disabled = not value

func _on_PlayButton_continue_clicked() -> void:
	if enabled:
		Global.emit_signal("level_selected", cityName)
