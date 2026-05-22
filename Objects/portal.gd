extends Node3D
@export var next_scene_path : String

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("TOUCHED:", body.name)
	if body.is_in_group("player"):
		var current_scene = get_tree().current_scene.name.strip_edges().to_lower()
		print("CURRENT SCENE RAW:", get_tree().current_scene.name)
		print("CURRENT SCENE NORMALIZED:", current_scene)

		# WORLD 3 -> WORLD 2 (NO REQUIREMENTS)
		if current_scene == "world_3":
			SoundManager.get_node("PortalEnter").play()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			await get_tree().create_timer(0.5).timeout
			if next_scene_path != "":
				get_tree().change_scene_to_file(next_scene_path)
			else:
				print("NO SCENE ASSIGNED!")
			return

		# WORLD 2 -> WORLD (4 NOTES REQUIRED)
		if current_scene == "world2" or current_scene == "world_2":
			print("NOTES COLLECTED:", body.notes_collected)
			if body.notes_collected >= 4:
				SoundManager.get_node("PortalEnter").play()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				await get_tree().create_timer(0.5).timeout
				if next_scene_path != "":
					get_tree().change_scene_to_file(next_scene_path)
				else:
					print("NO SCENE ASSIGNED!")
			else:
				print("PORTAL LOCKED - NOTES:", body.notes_collected)
			return

		# NORMAL PORTAL CHECK (other scenes)
		if body.can_enter_portal():
			SoundManager.get_node("PortalEnter").play()
			body.reset_counts()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			await get_tree().create_timer(0.5).timeout
			if next_scene_path != "":
				get_tree().change_scene_to_file(next_scene_path)
			else:
				print("NO SCENE ASSIGNED!")
		else:
			print("Portal Locked!")
