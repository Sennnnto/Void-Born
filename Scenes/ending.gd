extends CanvasLayer

@onready var video = $VideoStreamPlayer


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	video.play()


func _on_video_stream_player_finished():
	# Close game immediately after video ends
	get_tree().quit()
