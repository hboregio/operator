extends Control

onready var player: AnimationPlayer = $AnimationPlayer

func animate_in():
	visible = true
	player.stop(true)
	player.play("Animate")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	visible = false
