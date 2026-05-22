extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 5.0

const MAX_SCORE = 10
const MAX_GOLD = 10
const MAX_NOTES = 4

var current_speed = WALK_SPEED
var sensitivity = 0.002
var onCooldown = false

# FALSE in world 1
# TRUE after entering world 2
var upgrades_unlocked = false

var sword_level = 1
var next_upgrade_cost = 5
var hp = 100
var gold = 0
var maxHp = 100
var damage = 10
var target = []
var score = 0
var notes_collected = 0
var upgrade_timer = 0.0
var is_dead = false

@onready var upgradeLabel = $HUD/UpgradeLabel
@onready var goldLabel = $HUD/GoldLabel
@onready var scoreLabel = $HUD/ScoreLabel
@onready var hpBar = $HUD/HpBar
@onready var camera = $FirstPerson
@onready var animationPlayer = $AnimationPlayer
@onready var cooldown = $AttackCooldown
@onready var footsteps = $Footsteps
@onready var notesLabel = $HUD/NotesLabel

func player():
	pass

func reset_counts():
	score = 0
	gold = 0

func _ready():
	add_to_group("player")
	$FirstPerson.current = true
	hpBar.max_value = 100
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var current_scene = get_tree().current_scene.name

	if current_scene == "World2":
		upgrades_unlocked = true
		show_upgrade_text("Sword Upgrades Unlocked!")

func update_score():
	score = clamp(score, 0, MAX_SCORE)
	scoreLabel.text = "Enemies: " + str(score) + "/10"

func update_gold():
	gold = clamp(gold, 0, MAX_GOLD)
	goldLabel.text = "Gold: " + str(gold) + "/10"

func can_enter_portal() -> bool:
	var current_scene = get_tree().current_scene.name

	match current_scene:
		"World":
			return false  # no portal in final world, boss handles ending
		"World2":
			return score >= 5 and gold >= 5
		"World3":
			return score >= 10 and gold >= 10

	return false

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED
	else:
		current_speed = WALK_SPEED

	var input_dir := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

	var direction := (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# FOOTSTEPS
	var is_moving = input_dir != Vector2.ZERO

	if is_moving and is_on_floor():
		if not footsteps.playing:
			footsteps.play()

		if Input.is_action_pressed("sprint"):
			footsteps.pitch_scale = randf_range(0.85, 0.95)
		else:
			footsteps.pitch_scale = randf_range(0.70, 0.80)
	else:
		footsteps.stop()

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotation.x -= (event.relative.y * sensitivity)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

func attack():
	if Input.is_action_just_pressed("attack") and onCooldown == false:
		animationPlayer.play("SwordSwing")
		onCooldown = true
		cooldown.start()
		$SwordSound.play()

func deal_damage():
	for enemies in target:
		if is_instance_valid(enemies):
			enemies.hp -= damage

func update_HUD():
	hpBar.value = hp

	if hp <= 0 and is_dead == false:
		is_dead = true
		die()

func die():
	SoundManager.get_node("DeathSound").play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func _process(delta):
	if is_dead:
		return

	attack()
	update_HUD()
	update_score()
	update_gold()
	update_notes()

	if upgrades_unlocked:
		check_sword_upgrade()

	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	if upgrade_timer > 0:
		upgrade_timer -= delta
		if upgrade_timer <= 0:
			upgradeLabel.visible = false

func check_sword_upgrade():
	if gold >= next_upgrade_cost:
		gold -= next_upgrade_cost
		sword_level += 1

		match sword_level:
			2:
				damage = 15
				next_upgrade_cost = 10
				show_upgrade_text("Sword Upgraded! Level 2")
			3:
				damage = 25
				next_upgrade_cost = 20
				show_upgrade_text("Sword Upgraded! Level 3")
			4:
				damage = 40
				show_upgrade_text("Sword Max Level!")

func show_upgrade_text(text: String):
	upgradeLabel.text = text
	upgradeLabel.visible = true
	upgrade_timer = 2.0

func update_notes():
	notes_collected = clamp(notes_collected, 0, MAX_NOTES)
	notesLabel.text = "Notes: " + str(notes_collected) + "/4"

func _on_attack_cooldown_timeout() -> void:
	onCooldown = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "SwordSwing":
		animationPlayer.play("Idle")

func _on_attack_zone_body_entered(body: Node3D) -> void:
	if body.has_method("enemy"):
		target.append(body)

func _on_attack_zone_body_exited(body: Node3D) -> void:
	if body.has_method("ensemy"):
		target.erase(body)
