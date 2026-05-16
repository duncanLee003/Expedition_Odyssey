extends Area2D

@export var itemRes: InventoryItem
@export var item_id: String
@export_multiline var description := ""

@export var pickup_distance := 50.0

var is_collected := false


func _ready():
	input_pickable = true  

	# 🚫 already collected in a previous scene
	if GameState.collected_items.get(item_id, false):
		queue_free()
		return

func _on_body_entered(body):

	if is_collected:
		return

	if body.is_in_group("player"):
		collect(body)

func _input_event(viewport, event, shape_idx):
	if is_collected:
		return

	if event is InputEventMouseButton and event.pressed:

		var player = get_tree().get_first_node_in_group("player")
		if !player:
			return

		var dist = player.global_position.distance_to(global_position)

		if dist > pickup_distance:
			show_message("Too far away")
			return

		is_collected = true
		call_deferred("collect", player)


func collect(player):
	print("COLLECTED ITEM:", item_id)
	print("CURRENT WIRES:", GameState.wires_collected)

	if !player or !player.inventory:
		return

	# add item
	player.inventory.insert(itemRes)

	# wire logic FIRST
	if item_id.begins_with("wire_") and not GameState.collected_items.get(item_id, false):

		GameState.wires_collected += 1
		print("WIRE ADDED:", GameState.wires_collected)
		
		if GameState.wires_collected >= GameState.wires_required:
			show_message("You have enough wires now")

	# NOW save state AFTER
	GameState.collected_items[item_id] = true

	# blaster unlock
	if item_id == "blaster":
		player.has_blaster = true

	queue_free()


func show_message(text):
	var im = get_tree().get_first_node_in_group("interaction_manager")
	if im:
		im.show_message(text)
