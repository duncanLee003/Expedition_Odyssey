extends RigidBody2D

@export var max_speed := 150.0
@export var box_id := "box_1"

func _ready():

	lock_rotation = true

	add_to_group("activator")

	# wait for physics to initialize
	await get_tree().physics_frame

	# restore saved position
	if GameState.box_positions.has(box_id):

		global_position = GameState.box_positions[box_id]


func _physics_process(delta):

	# limit speed
	if linear_velocity.length() > max_speed:

		linear_velocity = linear_velocity.normalized() * max_speed

	# save position ONLY while moving
	if linear_velocity.length() > 1.0:

		GameState.box_positions[box_id] = global_position
