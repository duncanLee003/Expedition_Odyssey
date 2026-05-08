extends StaticBody2D

@export var move_distance := 100.0
@export var move_speed := 2.0

var start_position: Vector2
var target_position: Vector2
var is_active := false

func _ready():
	start_position = global_position
	target_position = start_position - Vector2(move_distance, 0)

func set_active(state: bool):
	is_active = state

func _process(delta):
	var destination = target_position if is_active else start_position
	
	global_position = global_position.lerp(destination, move_speed * delta)
