extends Area2D

@export var wire_id := "A"

func _ready():
	input_pickable = true


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("CLICK REGISTERED:", name)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		var manager = get_tree().get_first_node_in_group("wire_manager")
		if manager == null:
			return

		if event.pressed:
			manager.start_wire(self)
		else:
			manager.end_wire(self)
