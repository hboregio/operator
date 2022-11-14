extends Control

signal scene_transition_exit_complete

onready var player: AnimationPlayer = $AnimationPlayer

var callback

func animate(callback_reference):
	self.callback = callback_reference
	player.stop(true)
	visible = true
	player.play("Animate")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	visible = false
	emit_signal("scene_transition_exit_complete", callback)
