extends Area2D

@export var puzzle_ui: Node

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("CLICKED")

		if puzzle_ui:
			puzzle_ui.open()
