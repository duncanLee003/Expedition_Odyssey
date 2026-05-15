extends Control

@onready var label = $Panel/Label
@onready var choice_container = $Panel/ChoiceContainer

var dialogue_data = {}
var current_node = ""

var is_open := false
var dialogue_lines: Array[String] = []
var current_line := 0
var speaker := ""

func _ready():

	add_to_group("dialogue_box")

	visible = false
func start_dialogue(data, start_node := "start"):

	dialogue_data = data
	current_node = start_node

	visible = true
	show_node()


func show_node():

	var node = dialogue_data[current_node]

	label.text = node["text"]

	if node.has("event"):

		match node["event"]:

			"robot_password":
				if !GameState.robot_password_learned:
					GameState.robot_password_learned = true
					Journal.updated.emit()

					var im = get_tree().get_first_node_in_group("interaction_manager")
					if im:
						im.show_message("Journal Updated")

	# clear old buttons
	for child in choice_container.get_children():
		child.queue_free()



	# branching choices
	if node.has("choices"):

		for choice in node["choices"]:

			var btn = Button.new()

			btn.text = choice["text"]

			btn.custom_minimum_size = Vector2(100, 20)
			btn.add_theme_font_size_override("font_size", 12)

			btn.pressed.connect(
				func():
					current_node = choice["next"]
					show_node()
			)

			choice_container.add_child(btn)

	else:
		# no choices = click to continue/end
		pass

func show_dialogue(npc_name: String, lines: Array[String]):

	visible = true
	is_open = true

	speaker = npc_name
	dialogue_lines = lines
	current_line = 0

	show_current_line()
func show_current_line():

	if current_line >= dialogue_lines.size():
		close_dialogue()
		return

	label.text = speaker + ": " + dialogue_lines[current_line]

func close_dialogue():

	visible = false
	is_open = false

func _input(event):

	if !visible:
		return

	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		var node = dialogue_data[current_node]

		# don't continue if choices visible
		if node.has("choices"):
			return

		if node.has("next"):
			current_node = node["next"]
			show_node()
		else:
			close_dialogue()
