extends CanvasLayer

@onready var jumpscare = $"JumpScare"
@onready var sound = $"JumpScare Sound"

var can_trigger = false

func _ready():
	jumpscare.visible = false
	
	# Small delay before detection starts
	await get_tree().create_timer(1.0).timeout
	can_trigger = true

func trigger_jumpscare():
	jumpscare.visible = true
	sound.play()

	await get_tree().create_timer(1.5).timeout

	jumpscare.visible = false

func _on_area_3d_body_entered(body):
	if not can_trigger:
		return

	# Only trigger if the player entered
	if body.name == "Player":
		trigger_jumpscare()
