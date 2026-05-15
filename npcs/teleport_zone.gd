extends Area2D

@export var spawn_point: NodePath
@export var damage := 20

@onready var spawn = get_node(spawn_point)

func _on_body_entered(body):

	if body.is_in_group("player"):

		teleport_and_damage(body)

func teleport_and_damage(player):


	if player.has_method("take_damage"):
		player.take_damage(damage)

	# 🚀 teleport after
	player.global_position = spawn.global_position
