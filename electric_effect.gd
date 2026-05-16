extends CanvasLayer

@onready var anim = $AnimatedSprite2D

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func play():
	visible = true
	anim.play("shock")

	await anim.animation_finished

	visible = false
