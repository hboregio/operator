extends Node2D

onready var player: AnimationPlayer = $AnimationPlayer

func start():
	player.play("Rotation")

func stop():
	player.stop(true)
