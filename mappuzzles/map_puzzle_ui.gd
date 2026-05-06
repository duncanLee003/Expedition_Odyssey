extends Node2D

signal map_completed

var completed := false


func check_complete():
	if completed:
		return

	for piece in get_tree().get_nodes_in_group("map_pieces"):
		if not piece.locked:
			return

	_on_map_completed()
	


func _on_map_completed():
	if completed:
		return

	completed = true
	GameState.map_completed = true

	emit_signal("map_completed")

	var im = get_tree().get_first_node_in_group("interaction_manager")

	if im:
		im.show_message("Map added to [Pages] in the journal")
		return
