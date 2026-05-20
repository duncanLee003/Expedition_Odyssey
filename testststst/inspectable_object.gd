extends Area2D

@export_multiline var dialogue_text := "Placeholder text"

@export var interact_distance := 70.0

func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		var player = get_tree().get_first_node_in_group("player")

		if !player:
			return

		var dist = player.global_position.distance_to(global_position)

		if dist > interact_distance:
			return

		open_dialogue()


func open_dialogue():

	var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")

	if dialogue_ui:
		dialogue_ui.show_dialogue(dialogue_text)
