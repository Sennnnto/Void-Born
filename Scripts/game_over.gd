extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# STOP ALL MUSIC FIRST
	SoundManager.get_node("SoundMenu").stop()
	SoundManager.get_node("WorldOne").stop()
	SoundManager.get_node("WorldTwo").stop()
	SoundManager.get_node("WorldThree").stop()

	await get_tree().create_timer(1.8).timeout
	SoundManager.get_node("GameOver").play()


# =========================
# HOVER SOUNDS
# =========================

func _on_button_mouse_entered() -> void:
	SoundManager.get_node("EnterButton").play()


func _on_button_2_mouse_entered() -> void:
	SoundManager.get_node("QuitButton").play()


# =========================
# CLICK SOUNDS
# =========================

func _on_button_pressed() -> void:

	# STOP GAME OVER MUSIC
	SoundManager.get_node("GameOver").stop()

	SoundManager.get_node("EnterConfirm").play()

	await get_tree().create_timer(0.3).timeout

	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_button_2_pressed() -> void:

	# STOP GAME OVER MUSIC
	SoundManager.get_node("GameOver").stop()

	SoundManager.get_node("QuitConfirm").play()

	await get_tree().create_timer(0.3).timeout

	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
