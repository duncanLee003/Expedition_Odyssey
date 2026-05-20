extends Area2D

@export_multiline var message := "Press W to interact"
@export var trigger_once := true

var triggered := false

func _ready():
	body_entered.connect(_on_body_entered)



func _on_body_entered(body):

	if !body.is_in_group("player"):
		return

	if trigger_once and triggered:
		return

	triggered = true

	var ui = get_tree().get_first_node_in_group("dialogue_ui")

	if ui:
		await get_tree().create_timer(0.3).timeout
		ui.show_message(message)
