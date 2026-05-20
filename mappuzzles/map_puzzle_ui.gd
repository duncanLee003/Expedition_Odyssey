extends Control

signal map_completed

@onready var exit_button = $ExitButton

var completed := false
var ui_initialized := false


func _ready():

	add_to_group("map_puzzle_ui")

	visible = false
	exit_button.visible = false

	completed = GameState.map_completed

	if completed:
		return

	# only show when condition met
	if GameState.collected_map_pieces >= 4:
		open()


# -------------------------
# OPEN UI
# -------------------------
func open():

	visible = true
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	exit_button.visible = true

	# IMPORTANT: DO NOT hide children manually anymore
	ui_initialized = true

	print("MAP PUZZLE OPENED")


# -------------------------
# CHECK COMPLETION
# -------------------------
func check_complete():

	if completed:
		return

	for piece in get_tree().get_nodes_in_group("map_pieces"):

		if not piece.locked:
			return

	complete_puzzle()


# -------------------------
# COMPLETE PUZZLE
# -------------------------
func complete_puzzle():

	if completed:
		return

	completed = true
	GameState.map_completed = true

	remove_map_pieces()

	exit_button.visible = true

	print("MAP COMPLETED")

	map_completed.emit()

	var ui = get_tree().get_first_node_in_group("dialogue_ui")
	if ui:
		ui.show_message("Map added to [Pages] in the journal")


# -------------------------
# REMOVE INVENTORY PIECES
# -------------------------
func remove_map_pieces():

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var inventory = player.inventory

	for i in range(inventory.slots.size()):

		var slot = inventory.slots[i]

		if slot.item and slot.item.item_type == "map_piece":
			slot.item = null
			slot.amount = 0

	inventory.updated.emit()


# -------------------------
# EXIT UI
# -------------------------
func _on_exit_button_pressed():

	visible = false
	exit_button.visible = false

	process_mode = Node.PROCESS_MODE_DISABLED

	get_tree().paused = false
	get_viewport().gui_release_focus()

	print("MAP PUZZLE CLOSED")


# -------------------------
# SAFE RESET (ONLY GAME STATE, NOT VISUALS)
# -------------------------
func reset_state():

	# DO NOT touch visibility of children
	completed = false
