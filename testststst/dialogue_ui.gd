extends Control

@onready var label = $Panel/Label
@onready var choices_container = $Panel/ChoicesContainer

var dialogue_data := {}
var current_node := ""

var is_open := false

var full_text := ""
var current_text := ""

var char_index := 0
var text_speed := 0.02

var typing := false

func _ready():
	add_to_group("dialogue_ui")
	visible = false

func show_message(text: String):
	visible = true
	is_open = true

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.lock_movement()

	clear_choices()

	show_dialogue_text(text)
# -----------------------------------
# OPEN DIALOGUE
# -----------------------------------
func start_dialogue(data: Dictionary, start_node := "start"):
	dialogue_data = data
	current_node = start_node

	visible = true
	is_open = true

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.lock_movement()

	show_node(current_node)

func show_node(node_id: String):
	var node = dialogue_data.get(node_id, null)
	if node == null:
		close_dialogue()
		return

	current_node = node_id

	# clear old choices
	clear_choices()

	# show text
	show_dialogue_text(node.get("text", ""))

	# show choices OR auto-next
	if node.has("choices"):
		show_choices(node["choices"])
	else:
		# auto-advance or close
		if node.has("next"):
			await get_tree().create_timer(0.5).timeout
			show_node(node["next"])
		else:
			await get_tree().create_timer(0.5).timeout
			close_dialogue()
func show_dialogue_text(text: String):
	full_text = text
	current_text = ""
	char_index = 0
	label.text = ""

	start_typewriter()
# -----------------------------------
# TYPEWRITER
# -----------------------------------
func show_choices(choices: Array):
	for c in choices:
		var btn = Button.new()
		btn.text = c["text"]

		btn.pressed.connect(func():
			on_choice_selected(c)
		)

		choices_container.add_child(btn)
	
func on_choice_selected(choice: Dictionary):
	clear_choices()

	if choice.has("next"):
		show_node(choice["next"])
	else:
		close_dialogue()

func clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

func start_typewriter():

	typing = true

	while char_index < full_text.length():

		current_text += full_text[char_index]

		label.text = current_text

		char_index += 1

		await get_tree().create_timer(text_speed).timeout

	typing = false

# -----------------------------------
# CLOSE
# -----------------------------------

func close_dialogue():
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.unlock_movement()

	visible = false
	is_open = false

# -----------------------------------
# INPUT
# -----------------------------------

func _input(event):

	if !is_open:
		return

	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		# finish instantly
		if typing:

			typing = false

			label.text = full_text
			char_index = full_text.length()

			return

		# otherwise close
		# only close if no choices exist
		if choices_container.get_child_count() == 0:
			close_dialogue()
