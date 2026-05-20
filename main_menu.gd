extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("")


func _on_settings_pressed() -> void:
	

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("")
