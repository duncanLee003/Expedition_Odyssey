extends Area2D

@export var itemRes: InventoryItem
@export var item_id: String

@export var pickup_distance := 50.0

var is_collected := false


func _ready():
	input_pickable = true  


func _input_event(viewport, event, shape_idx):
	if is_collected:
		return

	if event is InputEventMouseButton and event.pressed:

		var player = get_tree().get_first_node_in_group("player")
		var interaction_manager = get_tree().get_first_node_in_group("interaction_manager")
		if !player:
			return

		var dist = player.global_position.distance_to(global_position)

		if dist > pickup_distance:
			show_message("Too far away")
			return

		is_collected = true
		call_deferred("collect", player)
		
		if interaction_manager:
			interaction_manager.show_message("Artifact collected.")


func collect(player):
	# safety check
	if !player or !player.inventory:
		return

	# add item
	Journal.add_artifact(item_id)

	# wire logic
	if item_id == "wire":
		GameState.wires_collected += 1

		if GameState.wires_collected == GameState.wires_required:
			show_message("You have enough wires now")


	# blaster unlock
	if item_id == "blaster":
		player.has_blaster = true

	queue_free()


func show_message(text):
	var im = get_tree().get_first_node_in_group("interaction_manager")
	if im:
		im.show_message(text)


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return

	if body.is_in_group("player"):
		collect(body)
