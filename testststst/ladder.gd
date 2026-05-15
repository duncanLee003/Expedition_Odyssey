extends Area2D

func _on_body_entered(body):

	if body.is_in_group("player"):
		body.is_on_ladder = true

func _on_body_exited(body):

	if body.is_in_group("player"):
		body.is_on_ladder = false
