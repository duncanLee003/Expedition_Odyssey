extends StaticBody2D

@export var max_health := 30
var current_health := 0

func _ready():
	current_health = max_health

func take_damage(amount: int):

	current_health -= amount
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE


	if current_health <= 0:
		break_object()

func break_object():

	queue_free()
