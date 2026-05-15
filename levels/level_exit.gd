extends Area2D


	
func _on_body_entered(body):
	if body.is_in_group("player"):
		trigger_level_complete()
		
		
func trigger_level_complete():
	var ui = get_tree().get_first_node_in_group("end_screen")
	if ui:
		ui.show_screen("Level Complete!")
		
