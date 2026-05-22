extends Node3D


@export var loot : PackedScene

var timerStarded = false

func _process(delta):
	if get_child_count() <= 1 and timerStarded == false:
		$Timer.start()
		timerStarded = true

func _on_timer_timeout():
	var instance = loot.instantiate()
	add_child(instance)
	timerStarded = false
