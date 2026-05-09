extends Node2D

var speed: float = 600
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	global_position += direction * speed * delta
