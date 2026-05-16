extends Node2D

@onready var map_image = $MapImage  
@onready var notification_icon = $"../JournalButton/NotificationJournal"

func _ready():

	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_to_group("wire_puzzle_ui")

	print("WIRE UI ENTERED TREE")
	print("STATE:", GameState.map_completed)

	if GameState.map_completed:
		show_map()

func show_map():
	map_image.visible = true
	print("CHECK")

func open():

	show()

	get_tree().paused = true

	call_deferred("refresh_state")

	var im = get_tree().get_first_node_in_group("interaction_manager")

	if GameState.wires_collected < GameState.wires_required:

		if im:
			im.show_message("You need more wires")

			GameState.current_quest = "fix_wire"

			notification_icon.visible = true

			var journal = get_tree().get_first_node_in_group("journal_update")

			if journal:
				journal.show_update()

			return
func refresh_state():
	if GameState.map_completed:
		show_map()

func close():
	hide()
	get_tree().paused = false

func _on_close_button_pressed():
	close()
