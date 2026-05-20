extends Control

func show_screen(text: String):
	get_tree().paused = true
	visible = true



func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_next_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/truelevel_2.tscn")


func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
