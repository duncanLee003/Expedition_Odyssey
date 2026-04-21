extends Node2D


@onready var player = get_tree().get_first_node_in_group("player")


@onready var message_label = get_tree().get_first_node_in_group("ui_message")

func _ready():
	add_to_group("interaction_manager")

func show_message(text: String, duration: float = 2.0):
	message_label.text = text
	message_label.modulate.a = 0
	message_label.show()
	
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1, 0.3)
	
	await get_tree().create_timer(duration).timeout
	
	var tween2 = create_tween()
	tween2.tween_property(message_label, "modulate:a", 0, 0.3)
	await tween2.finished
	
	message_label.hide()
