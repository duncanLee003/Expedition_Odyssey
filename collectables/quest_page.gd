extends Control

@onready var quest_image = $TextureRect
@onready var quest_label = $Label

@export var no_quest_texture : Texture2D
@export var key_quest_texture : Texture2D
@export var door_quest_texture : Texture2D

func _process(delta):
	update_quest_ui()

func update_quest_ui():

	match GameState.current_quest:

		"none":
			quest_label.text = "No active objective."
			quest_image.texture = no_quest_texture

		"find_key":
			quest_label.text = "Find the laboratory keycard."
			quest_image.texture = key_quest_texture

		"fix_wire":
			quest_label.text = "Find 7 wires."
			quest_image.texture = key_quest_texture
		
		"activate_robot":
			quest_label.text = "Find something to activate the robot."
			quest_image.texture = door_quest_texture
			
		"find_password":
			quest_label.text = "Find the password to shut down the lasers."
			quest_image.texture = door_quest_texture
			
		"find_sequence":
			quest_label.text = "Maybe that first computer has the solution."
			quest_image.texture = door_quest_texture
