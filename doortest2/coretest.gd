extends Node2D


@onready var wire_manager = get_tree().get_first_node_in_group("wire_manager")
@onready var darkness = get_node("/root/TLevel1/Darkness")
@onready var green_light = get_node("/root/TLevel1/GreenFilter")

signal powered_on

func _ready():
	add_to_group("core")
	wire_manager = get_tree().get_first_node_in_group("wire_manager")

	if GameState.core_powered:
		apply_powered_state()
	if wire_manager:
		wire_manager.puzzle_completed.connect(_on_puzzle_completed)
		
func _on_puzzle_completed():
	$AnimatedSprite2D.play("turningon")
	await $AnimatedSprite2D.animation_finished
	GameState.core_powered = true
	powered_on.emit()

	darkness.visible = false
	green_light.visible = true

func apply_powered_state():
	$AnimatedSprite2D.play("turningon")
	$AnimatedSprite2D.frame = $AnimatedSprite2D.sprite_frames.get_frame_count("turningon") - 1
