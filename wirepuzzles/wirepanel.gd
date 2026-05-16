extends Area2D

@export var interact_distance := 80.0

var player = null


func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	player = get_tree().get_first_node_in_group("player")

	input_pickable = true


func _input(event):

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		if !player:
			player = get_tree().get_first_node_in_group("player")

		if !player:
			return

		# player distance check
		var dist = player.global_position.distance_to(global_position)

		if dist > interact_distance:
			return

		# mouse overlap check
		if !_is_mouse_over():
			return

		print("WIRE PANEL CLICKED")

		var puzzle_ui = get_tree().get_first_node_in_group("wire_puzzle_ui")

		if puzzle_ui:
			puzzle_ui.open()


func _is_mouse_over() -> bool:

	var mouse_pos = get_global_mouse_position()

	for child in get_children():

		if child is CollisionShape2D:

			var shape = child.shape

			if shape is RectangleShape2D:

				var rect_size = shape.size
				var rect_pos = child.global_position - rect_size / 2.0

				var rect = Rect2(rect_pos, rect_size)

				if rect.has_point(mouse_pos):
					return true

	return false
