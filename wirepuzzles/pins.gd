extends Area2D

@export var wire_id := ""  # e.g. "A", "B"

signal clicked(pin)
signal released(pin)

func _ready():
	add_to_group("pins")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
		else:
			released.emit(self)
