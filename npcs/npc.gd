extends Area2D

@export var inactive_texture: Texture2D
@export var active_texture: Texture2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var notification_icon = $"../CanvasLayer/JournalButton/NotificationJournal"

@export var npc_name := "Broken Robot"
@export var dialogue_data := {
	"start": {
		"text": "Systems online. Hello?",
		"choices": [
			{
				"text": "Who are you?",
				"next": "who"
			},
			{
				"text": "How do I get off this planet?",
				"next": "password"
			},
			{
				"text": "Goodbye.",
				"next": "bye"
			}
		]
	},

	"who": {
		"text": "I am a maintenance bot.",
		"next": "start"
	},

	"password": {
		"text": "Unfortunately, due to the shield protecting the planet, you cannot escape. But if you want to advance, the password is ORBIT-17", 
		"next": "start",
		"event": "robot_password"
	},

	"bye": {
		"text": "Goodbye human."
	}
}
@export var interact_distance := 70.0

var player
var current_line := 0
var is_activated := false

@export var inactive_message := "The robot is inactive."



func _ready():

	player = get_tree().get_first_node_in_group("Player")

	is_activated = GameState.robot_activated

	if is_activated:
		sprite.texture = active_texture

func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		interact()
func interact():

	if !is_activated:

		try_insert_usb()
		return

	talk()

func talk():

	var db = get_tree().get_first_node_in_group("dialogue_box")

	if db:
		db.start_dialogue(dialogue_data)

func show_dialogue():

	var db = get_tree().get_first_node_in_group("dialogue_box")

	if db:
		db.start_dialogue(dialogue_data)

func show_message(text):

	var im = get_tree().get_first_node_in_group("interaction_manager")

	if im:
		im.show_message(text)

func try_insert_usb():

	var hotbar = get_tree().get_first_node_in_group("hotbar")

	if !hotbar:
		return

	var selected = hotbar.get_selected_item()

	# correct item
	if selected and selected.name == "usb":

		activate_robot()

	else:
		show_message(inactive_message)
		GameState.current_quest = "activate_robot"
		notification_icon.visible = true
		var journal = get_tree().get_first_node_in_group("journal_update")

		if journal:
			journal.show_update()
		return

func activate_robot():

	is_activated = true
	GameState.robot_activated = true

	show_message("Robot activated.")

	sprite.texture = active_texture
	sprite.modulate = Color(1.5, 1.5, 1.5)
	
	var tween = create_tween()

	tween.tween_property(sprite, "modulate", Color.BLACK, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
