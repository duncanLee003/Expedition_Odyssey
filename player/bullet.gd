extends Area2D

@export var speed := 600.0
@export var damage := 10

var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()

	if body.has_method("take_damage"):

		body.take_damage(damage)

	queue_free()
