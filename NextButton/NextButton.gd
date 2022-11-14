extends Button

signal continue_clicked

onready var continueButton = get_node(".")

func _on_Continue_pressed():
	emit_signal("continue_clicked")

func _on_Button_down():
	continueButton.set_scale (Vector2(0.9, 0.9))

func _on_Button_up():
	continueButton.set_scale (Vector2(1, 1))
	emit_signal("continue_clicked")
