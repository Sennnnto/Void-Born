extends Control

func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# ==========================
	# FULLSCREEN BACKGROUND FIX
	# ==========================
	var bg = get_node_or_null("Background")

	if bg:
		var viewport_size = get_viewport().get_visible_rect().size

		# Get texture from current frame
		var tex = bg.sprite_frames.get_frame_texture(bg.animation, bg.frame)

		if tex:
			var texture_size = tex.get_size()

			# Scale while keeping aspect ratio
			var scale_factor = max(
				viewport_size.x / texture_size.x,
				viewport_size.y / texture_size.y
			)

			bg.scale = Vector2(scale_factor, scale_factor)

			# Center the sprite
			bg.centered = true
			bg.position = viewport_size / 2

	else:
		print("Background AnimatedSprite2D not found!")

	# Play menu music
	SoundManager.get_node("SoundMenu").play()


# ==========================
# HOVER SOUNDS
# ==========================

func _on_start_game_mouse_entered() -> void:
	SoundManager.get_node("EnterButton").play()


func _on_quit_mouse_entered() -> void:
	SoundManager.get_node("QuitButton").play()


# ==========================
# CLICK BUTTONS
# ==========================

func _on_start_game_pressed() -> void:

	SoundManager.get_node("SoundMenu").stop()
	SoundManager.get_node("EnterConfirm").play()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	await get_tree().create_timer(0.7).timeout

	get_tree().change_scene_to_file("res://Scenes/world_3.tscn")


func _on_quit_pressed() -> void:

	SoundManager.get_node("SoundMenu").stop()
	SoundManager.get_node("QuitConfirm").play()

	await get_tree().create_timer(0.5).timeout

	get_tree().quit()
