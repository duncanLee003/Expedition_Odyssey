extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var message_label = get_tree().get_first_node_in_group("ui_message")

func _ready():

	add_to_group("interaction_manager")

	# allows messages during paused UIs
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func show_message(text: String, duration: float = 2.0):

	var message_label = get_tree().get_first_node_in_group("ui_message")

	if !message_label:
		return

	# reset state
	message_label.text = text
	message_label.visible = true
	message_label.modulate.a = 0.0

	# ----------------------------
	# FADE IN
	# ----------------------------
	var fade_in = create_tween()

	fade_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	fade_in.tween_property(
		message_label,
		"modulate:a",
		1.0,
		0.25
	)

	await fade_in.finished

	# label may be deleted after scene change
	if !is_instance_valid(message_label):
		return

	# ----------------------------
	# WAIT
	# ----------------------------
	await get_tree().create_timer(duration, true).timeout

	# label may be deleted during timer
	if !is_instance_valid(message_label):
		return

	# ----------------------------
	# FADE OUT
	# ----------------------------
	var fade_out = create_tween()

	fade_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	fade_out.tween_property(
		message_label,
		"modulate:a",
		0.0,
		0.25
	)

	await fade_out.finished

	# label may be deleted during fade
	if !is_instance_valid(message_label):
		return

	# ----------------------------
	# HIDE
	# ----------------------------
	message_label.visible = false
	message_label.modulate.a = 1.0
