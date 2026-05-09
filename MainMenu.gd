extends Control

@onready var main_buttons: VBoxContainer = $"Main Buttons"
@onready var settings = $Settings



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready():
	main_buttons.visible = true
	settings.visible = false

func _on_start_pressed():
	print("Start pressed")  # test first
	get_tree().change_scene_to_file("res://levels/truelevel_1.tscn")


func _on_settings_pressed() -> void:
	print("Settings pressed")
	main_buttons.visible = false
	settings.visible = true


func _on_quit_pressed():
	print("Quit pressed")  # test first
	get_tree().quit()


func _on_back_settings_pressed() -> void:
	_ready()
 
