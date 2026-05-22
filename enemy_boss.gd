extends CharacterBody3D

enum States {
	attack,
	idle,
	chase,
	die
}

var state = States.idle
var hp = 50
var damage = 15
var speed = 6.0
var acceleration = 10.0
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
		die()

	if attack_timer > 0:
		attack_timer -= delta


func die():
	if dead:
		return

	dead = true
	print("BOSS IS DEAD")

	state = States.die
	velocity = Vector3.ZERO

	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.score < 10:
			player.score += 1

	# stop movement immediately
	set_physics_process(false)
	set_process(false)

	if animationPlayer and animationPlayer.has_animation("Die"):
		animationPlayer.play("Die")

	# loot spawn
	if health_loot:
		var loot = health_loot.instantiate()
		get_tree().current_scene.add_child(loot)
		loot.global_position = global_position + Vector3(-0.5, 1.0, 0)

	if coin_loot:
		var coin = coin_loot.instantiate()
		get_tree().current_scene.add_child(coin)
		coin.global_position = global_position + Vector3(0.5, 1.0, 0)

	print("CHANGING SCENE NOW")

	# IMPORTANT: defer scene change to avoid physics crash
	call_deferred("_go_to_ending")


func _go_to_ending():
	SoundManager.get_node("WorldThree").stop()
	get_tree().change_scene_to_file("res://Scenes/ending.tscn")

func _physics_process(delta):
	if dead:
		return

	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	match state:

		States.idle:
			velocity.x = 0
			velocity.z = 0
			if animationPlayer:
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

				velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
				velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)

				if animationPlayer:
					animationPlayer.play("Walk")

		States.attack:
			velocity.x = 0
			velocity.z = 0

			if animationPlayer:
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
