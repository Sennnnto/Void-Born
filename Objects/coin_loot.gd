extends Area3D

@export var coin_value = 1
@export var rotation_speed = 3.0

var coin_mesh = null


func _ready():
	if get_child_count() > 1:
		coin_mesh = get_child(1)

	monitoring = true
	monitorable = true

	print("COIN READY")


func _process(delta):
	if coin_mesh:
		coin_mesh.rotate_y(rotation_speed * delta)

	var bodies = get_overlapping_bodies()

	for body in bodies:
		if body.is_in_group("player"):

			print("COIN PICKED UP")

			body.gold += coin_value

			if body.gold > 10:
				body.gold = 10

			# ✔ PLAY SOUND HERE
			var sfx = SoundManager.get_node_or_null("CoinPickup")
			if sfx:
				sfx.play()

			queue_free()
			return
