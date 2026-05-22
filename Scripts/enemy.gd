extends CharacterBody3D

enum States {
	attack,
	idle,
	chase,
	die
}

var state = States.idle
var hp = 15
var damage = 5
var speed = 4.0
var acceleration = 8.0
var target = null
var dead = false

var attack_timer = 0.0
var attack_cooldown = 1.0

@export var health_loot : PackedScene
@export var coin_loot : PackedScene

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@onready var animationPlayer: AnimationPlayer = $GobelinExport/AnimationPlayer


func enemy():
	pass


func _process(delta):

	if hp <= 0 and dead == false:
		dead = true

		var player = get_tree().get_first_node_in_group("player")

		if player:
			# Only increase enemy count
			if player.score < 10:
				player.score += 1

		die()

	if attack_timer > 0:
		attack_timer -= delta


func die():

	state = States.die
	velocity = Vector3.ZERO

	# Play death animation
	if animationPlayer:
		animationPlayer.play("Die")

	# Spawn health loot
	if health_loot:
		var loot = health_loot.instantiate()

		# Add to current scene
		get_tree().current_scene.add_child(loot)

		# Spawn near enemy
		loot.global_position = (
			global_position +
			Vector3(-0.5, 1.0, 0)
		)

		print("HEALTH DROPPED")

	# Spawn coin loot
	if coin_loot:

		var coin = coin_loot.instantiate()

		# Add coin safely to scene
		get_tree().current_scene.add_child(coin)

		# Spawn HIGHER so it won't clip underground
		coin.global_position = (
			global_position +
			Vector3(0.5, 1.0, 0)
		)

		print(
			"COIN SPAWNED AT: ",
			coin.global_position
		)

	else:
		print("coin_loot is EMPTY!")

	# Wait before removing enemy
	await get_tree().create_timer(1.5).timeout

	queue_free()


func _physics_process(delta):

	if dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	match state:

		States.idle:
			velocity.x = 0
			velocity.z = 0
			animationPlayer.play("Idle")

		States.chase:

			if target and is_instance_valid(target):

				look_at(
					Vector3(
						target.global_position.x,
						global_position.y,
						target.global_position.z
					),
					Vector3.UP
				)

				rotate_y(deg_to_rad(180))

				navAgent.target_position = target.global_position

				var direction = navAgent.get_next_path_position() - global_position

				direction.y = 0
				direction = direction.normalized()

				var target_velocity = direction * speed

				velocity.x = lerp(
					velocity.x,
					target_velocity.x,
					acceleration * delta
				)

				velocity.z = lerp(
					velocity.z,
					target_velocity.z,
					acceleration * delta
				)

				animationPlayer.play("Walk")

		States.attack:
			velocity.x = 0
			velocity.z = 0

			animationPlayer.play("Punch")

			if attack_timer <= 0:
				attack()
				attack_timer = attack_cooldown

		States.die:
			velocity = Vector3.ZERO

	move_and_slide()


func attack():

	if target and is_instance_valid(target):
		target.hp -= damage


func _on_chase_area_body_entered(body):

	if body.has_method("player"):
		target = body
		state = States.chase


func _on_chase_area_body_exited(body):

	if body.has_method("player"):
		target = null
		state = States.idle


func _on_attack_area_body_entered(body):

	if body.has_method("player"):
		target = body
		state = States.attack


func _on_attack_area_body_exited(body):

	if body.has_method("player"):
		state = States.chase
