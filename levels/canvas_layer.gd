extends CanvasLayer

var inventory = null


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	call_deferred("bind_inventory")
	call_deferred("reset_input_state")


func bind_inventory():
	inventory = get_tree().get_first_node_in_group("inventory_gui")


func reset_input_state():

	get_tree().paused = false
	get_viewport().gui_release_focus()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# IMPORTANT: prevents leftover UI blocking input after map puzzle
	get_tree().call_group("map_pieces", "set_process_input", true)

func _unhandled_input(event):
	if inventory == null:
		inventory = get_tree().get_first_node_in_group("inventory_gui")
		if inventory == null:
			return

	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()
