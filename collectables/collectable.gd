extends Area2D

@export var itemRes: InventoryItem
@export var item_id: String


func _ready():
	input_pickable = true  


@export var pickup_distance := 50.0

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var player = get_tree().get_first_node_in_group("player")
		if !player:
			return
		
		var dist = player.global_position.distance_to(global_position)
		
		if dist > pickup_distance:
			show_message("Too far away")
			return
		
		collect(player.inventory)

func show_message(text):
	var im = get_tree().get_first_node_in_group("interaction_manager")
	if im:
		im.show_message(text)

func collect(inventory: Inventory):
	# ALWAYS add item to inventory
	inventory.insert(itemRes)

	# ONLY count wires
	if item_id == "wire":
		GameState.wires_collected += 1

		if GameState.wires_collected == GameState.wires_required:
			show_message("You have enough wires now")

		print("Wires:", GameState.wires_collected)

	queue_free()
