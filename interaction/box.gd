extends RigidBody2D

@export var max_speed := 150.0

func _ready():
	lock_rotation = true

func _physics_process(delta):
	# limit speed so it doesn’t go crazy
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
