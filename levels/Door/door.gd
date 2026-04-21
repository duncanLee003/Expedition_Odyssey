extends Node2D

@export var next_scene: String

func _on_exit_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	var player = body

	# prevent movement immediately
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO

	# optional: disable input if you have input system
	if player.has_method("set_can_move"):
		player.set_can_move(false)

	# small delay before transition (feels better)
	await get_tree().create_timer(0.2).timeout

	SceneManager.transition_to_scene(next_scene)
