extends Control

@onready var input = $Panel/LineEdit
@onready var feedback = $Panel/Label
@onready var notification_icon = $"../JournalButton/NotificationJournal"

var correct_password := "ORBIT-17"

var is_open := false

func open():

	visible = true
	is_open = true
	get_tree().paused = true
	input.text = ""
	feedback.text = ""
	if !GameState.security_terminal_seen:

		GameState.security_terminal_seen = true

		var im = get_tree().get_first_node_in_group("interaction_manager")
		if im:
			im.show_message("What's the password?")
		GameState.current_quest = "find_password"
		notification_icon.visible = true
		var journal = get_tree().get_first_node_in_group("journal_update")

		if journal:
			journal.show_update()
		return


func close():
	get_viewport().gui_release_focus()
	visible = false
	is_open = false
	get_tree().paused = false

func _on_button_pressed():

	if input.text == correct_password:

		feedback.text = "ACCESS GRANTED"

		GameState.security_unlocked = true
		GameState.security_unlocked_changed.emit()

		_disable_system()

		await get_tree().create_timer(1.0, true).timeout

		close()

	else:

		feedback.text = "ACCESS DENIED"

func _disable_system():


	GameState.lasers_disabled = true
	var terminal = get_tree().get_first_node_in_group("security_terminal")

	if terminal:
		terminal.shutdown_terminal()


func _on_exit_button_pressed() -> void:
	close()
