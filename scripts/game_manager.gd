extends Node
@onready var cursor: Texture2D = preload("res://assets/normcursor.png")


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.32, 0.259, 0.857, 1.0))
	add_to_group("game_manager")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(24, 24))
