extends Area3D

@export var heal_amount = 20
@export var rotation_speed = 2.0

func _process(delta):
	rotate_y(rotation_speed * delta)


func _on_body_entered(body):
	if body.has_method("player"):

		body.hp += heal_amount
		body.hp = min(body.hp, body.maxHp)

		# ✔ PLAY SOUND HERE
		var sfx = SoundManager.get_node_or_null("HealthPickup")
		if sfx:
			sfx.play()

		queue_free()
