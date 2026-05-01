extends Node
@onready var cursor: Texture2D = preload("res://assets/normcursor.png")


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0x171736ff))
	add_to_group("game_manager")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(24, 24))
