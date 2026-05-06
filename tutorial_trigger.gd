extends Area2D

@export var message: String = "Press W to interact"
@export var trigger_once := true

var triggered := false

func _ready():
	body_entered.connect(_on_body_entered)

@onready var label = $Label

var hide_timer = null
var fade_tween = null

func show_message(text):
	if label == null:
		print("Label not found!")
		return

	label.text = text
	label.visible = true
	label.modulate.a = 1.0  # reset opacity

	# stop previous timer
	if hide_timer:
		hide_timer = null

	# stop previous tween
	if fade_tween:
		fade_tween.kill()

	# wait before fading (message display time)
	hide_timer = get_tree().create_timer(2.0)
	await hide_timer.timeout

	# fade out
	fade_tween = create_tween()
	fade_tween.tween_property(label, "modulate:a", 0.0, 1.0)

	await fade_tween.finished

	label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if trigger_once and triggered:
			return
		
		triggered = true
		show_message(message)
