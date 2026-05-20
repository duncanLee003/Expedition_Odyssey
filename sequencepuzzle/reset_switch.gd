extends Area2D

@onready var sprite = $Sprite2D

func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton and event.pressed:



		PressurePlatePuzzle.reset_puzzle()
func reset_puzzle():



	PressurePlatePuzzle.reset_puzzle()

	animate_switch()

func animate_switch():

	sprite.scale = Vector2(0.9, 0.9)

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.2)
