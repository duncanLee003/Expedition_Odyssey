extends Area2D


@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	PressurePlatePuzzle.puzzle_completed.connect(open_door)
	PressurePlatePuzzle.puzzle_reset.connect(close_door)


func open_door():
	print("Door opened")
	anim.play("open")
	$CollisionShape2D.set_deferred("disabled", true)


func close_door():
	print("Door reset")
	anim.play("closed")
	$CollisionShape2D.set_deferred("disabled", true)
