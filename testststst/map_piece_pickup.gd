extends Area2D

@export var piece_id := 0
@export var itemRes: InventoryItem
@export var pickup_distance := 80.0
@export var item_id := "item_1"

var collected := false

func _ready():

	# prevent respawn after collection
	if GameState.collected_items.get(item_id, false):

		queue_free()
		return

	input_pickable = true
	
func _input_event(viewport, event, shape_idx):

	if collected:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		var player = get_tree().get_first_node_in_group("player")
		if !player:
			return

		var dist = player.global_position.distance_to(global_position)

		if dist > pickup_distance:
	
			return

		collect(player)

func collect_from_click():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		collect(player)

func collect(player):

	if collected:
		return

	collected = true
	GameState.collected_items[item_id] = true
	var player_inventory = player.inventory

	if player_inventory:
		player_inventory.insert(itemRes)

	GameState.collected_map_pieces += 1



	# unlock after 4 pieces
	if GameState.collected_map_pieces >= 4:

		GameState.map_puzzle_unlocked = true

		var puzzle = get_tree().get_first_node_in_group("map_puzzle")

		if puzzle:
			puzzle.visible = true

		var im = get_tree().get_first_node_in_group("interaction_manager")

		if im:
			im.show_message("Map puzzle unlocked")

	queue_free()

func _on_body_entered(body):

	if collected:
		return

	if body.is_in_group("player"):
		collect(body)
