extends Node2D

signal map_completed
@onready var exit_button = $ExitButton
var completed := false

func _ready():
	print("MAP PIECES FOUND:", get_tree().get_nodes_in_group("map_pieces").size())
	visible = false
	exit_button.visible = false

	if GameState.collected_map_pieces >= 4:
		visible = true

func check_complete():

	print("CHECK COMPLETE")

	if completed:
		return

	for piece in get_tree().get_nodes_in_group("map_pieces"):

		print(piece.name, "LOCKED =", piece.locked)

		if not piece.locked:
			print("NOT LOCKED:", piece.name)
			return

	print("ALL LOCKED")

	_on_map_completed()


func _on_map_completed():
	if completed:
		return

	completed = true
	GameState.map_completed = true

	remove_map_pieces()
	exit_button.visible = true
	emit_signal("map_completed")

	var im = get_tree().get_first_node_in_group("interaction_manager")

	if im:
		print("MESSAGE CALLED")
		im.show_message("Map added to [Pages] in the journal")

func remove_map_pieces():

	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return

	var inventory = player.inventory

	for i in range(inventory.slots.size()):

		var slot = inventory.slots[i]

		if slot.item and slot.item.item_type == "map_piece":

			print("REMOVING:", slot.item.name)

			slot.item = null
			slot.amount = 0

	inventory.updated.emit()


func _on_exit_button_pressed():
	get_tree().paused = false
	visible = false
