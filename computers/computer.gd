extends Area2D

@export var interact_distance := 80.0

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		open_computer()


func open_computer():

	player = get_tree().get_first_node_in_group("player")
	if !player:
		return

	if player.global_position.distance_to(global_position) > interact_distance:
		return

	var ui = get_tree().get_first_node_in_group("computer_ui")
	if ui:
		ui.open_blank()
