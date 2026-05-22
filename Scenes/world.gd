extends Node3D


func _ready():
	# Play world music
	SoundManager.get_node(
		"WorldThree"
	).play()
