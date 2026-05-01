extends Control

@onready var main_buttons: VBoxContainer = $"Main Buttons"
@onready var settings = $Settings



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready():
	main_buttons.visible = true
	settings.visible = false

func _on_start_pressed() -> void:
	print("Start pressed")


func _on_settings_pressed() -> void:
	print("Settings pressed")
	main_buttons.visible = false
	settings.visible = true


func _on_quit_pressed() -> void:
	print("Quit pressed")


func _on_back_settings_pressed() -> void:
	_ready()
 
