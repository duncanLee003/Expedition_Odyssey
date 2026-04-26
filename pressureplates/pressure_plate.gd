extends Area2D

@export var platform_path: NodePath
@onready var platform = get_node_or_null(platform_path)

var bodies_on_plate: Array = []

func _ready():
	add_to_group("pressure_plate")

func is_valid_body(body):
	return body.is_in_group("activator")

func _on_body_entered(body):
	if is_valid_body(body):
		bodies_on_plate.append(body)
		update_state()

func _on_body_exited(body):
	if is_valid_body(body):
		bodies_on_plate.erase(body)
		update_state()

func update_state():
	var pressed = bodies_on_plate.size() > 0
	
	if platform:
		platform.set_active(pressed)
	else:
		push_warning("PressurePlate: platform not assigned!")
