extends Control

@onready var screen = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var blank_texture : Texture2D
@export var active_texture : Texture2D
@onready var usb_zone = $USBZone
@onready var notification_icon = $"../JournalButton/NotificationJournal"
var is_open := false
var is_activated := false

@onready var interact_cursor: Texture2D = preload("res://assets/pointcursor.png")
@onready var cursor: Texture2D = preload("res://assets/normcursor.png")

func _ready():
	mouse_entered.connect(_on_usb_zone_mouse_entered)
	mouse_exited.connect(_on_usb_zone_mouse_exited)
	add_to_group("computer_ui")
	
	close()

	



func open_blank():
	visible = true
	is_open = true
	get_tree().paused = true

	if !is_activated:
		screen.texture = blank_texture


func close():
	get_viewport().gui_release_focus()
	visible = false
	is_open = false
	get_tree().paused = false


func insert_usb():
	if is_activated:
		return

	is_activated = true
	screen.texture = active_texture


func _on_close_button_pressed():
	close()

func _on_usb_zone_pressed():
	try_insert_usb()
	
func try_insert_usb():

	var hotbar = get_tree().get_first_node_in_group("hotbar")
	if !hotbar:
		return

	var selected = hotbar.get_selected_item()

	if selected and selected.name == "usb":
		GameState.usb_inserted = true
		screen.texture = active_texture
		play_sound()
		var dialogue = get_tree().get_first_node_in_group("dialogue_ui")

		if dialogue:
			dialogue.show_message("Journal Updated")
	


	
		Journal.updated.emit()
	else:

		var dialogue = get_tree().get_first_node_in_group("dialogue_ui")

		if dialogue:
			dialogue.show_message("You're missing something.\nCome back later.")







func play_sound():
	audio.play()


func _on_usb_zone_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(interact_cursor, Input.CURSOR_ARROW, Vector2(24, 24))


func _on_usb_zone_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(24, 24))
