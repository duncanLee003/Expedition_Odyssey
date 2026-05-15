extends Area2D

@export var laser_id := "laser_1"
@onready var sprite: Sprite2D = $Sprite2D

var active := true

func _ready():

	GameState.security_unlocked_changed.connect(_on_security_changed)

	# also apply instantly on load
	_on_security_changed()
func _on_security_changed():

	if GameState.security_unlocked:
		disable_laser()

func _on_body_entered(body):

	if !active:
		return

	if body.is_in_group("player"):

		if body.has_method("die"):
			body.die()

func disable_laser():

	active = false

	$CollisionShape2D.disabled = true
	sprite.visible = false
	
