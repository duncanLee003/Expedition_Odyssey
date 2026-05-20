extends Control

@onready var map_image = $MapImage  
@onready var notification_icon = $"../JournalButton/NotificationJournal"

func _ready():

	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_to_group("wire_puzzle_ui")


	if GameState.map_completed:
		show_map()

func show_map():
	map_image.visible = true


func open():
	mouse_filter = Control.MOUSE_FILTER_PASS

	show()

	get_tree().paused = true

	call_deferred("refresh_state")

	var dialogue = get_tree().get_first_node_in_group("dialogue_ui")

	if GameState.wires_collected < GameState.wires_required:
		await get_tree().create_timer(1.0).timeout

		if dialogue:
			await get_tree().create_timer(1.0).timeout
			dialogue.show_message("You need more wires.")

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
	get_viewport().gui_release_focus()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()
	get_tree().paused = false

func _on_close_button_pressed():
	close()
