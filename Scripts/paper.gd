extends Area3D

var player_near = false
var player_ref = null

@onready var prompt = $Label3D


func _ready():
	prompt.visible = false


func _process(delta):

	if player_near:

		if Input.is_action_just_pressed("interact"):

			if player_ref != null:

				player_ref.notes_collected += 1
				player_ref.update_notes()

				queue_free()


func _on_body_entered(body):

	if body.is_in_group("player"):

		player_near = true
		player_ref = body
		prompt.visible = true


func _on_body_exited(body):

	if body.is_in_group("player"):

		player_near = false
		player_ref = null
		prompt.visible = false
