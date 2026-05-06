extends Node2D

@onready var map_image = $MapImage  

func _enter_tree():
	print("WIRE UI ENTERED TREE")
	print("STATE:", GameState.map_completed)

	if GameState.map_completed:
		show_map()

func show_map():
	map_image.visible = true
	print("CHECK")

func open():
	show()
	call_deferred("refresh_state")
	var im = get_tree().get_first_node_in_group("interaction_manager")
	if GameState.wires_collected < GameState.wires_required:
		if im:
			im.show_message("You need more wires")
			return
	
func refresh_state():
	if GameState.map_completed:
		show_map()

func close():
	hide()
	get_tree().paused = false

func _on_close_button_pressed():
	close()
