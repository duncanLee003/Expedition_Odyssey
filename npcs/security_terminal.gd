extends Area2D

@onready var ui = get_tree().get_first_node_in_group("security_terminal_ui")
@onready var anim = $AnimatedSprite2D

func _ready():

	add_to_group("security_terminal")

	# restore saved state
	if GameState.security_unlocked:
		anim.play("shutdown")


func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton and event.pressed:

		if ui:
			ui.open()


func shutdown_terminal():

	anim.play("shutdown")
