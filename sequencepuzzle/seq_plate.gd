extends Area2D
@export var press_sound: AudioStream
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var plate_id := "plate_1"


func _ready():
	add_to_group("pressure_plate")
	PressurePlatePuzzle.register_light(plate_id, $Light)


func _on_body_entered(body):

	if body.is_in_group("player"):

		play_sound()

		PressurePlatePuzzle.press_plate(plate_id)


func _on_body_exited(body):

	if body.is_in_group("player"):

		PressurePlatePuzzle.release_plate(plate_id)

func play_sound():

	if press_sound:
		audio.stream = press_sound
		audio.play()
