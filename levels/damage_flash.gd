extends ColorRect


func _ready():
	visible = true
	color = Color(0, 0, 0, 0)  # fully transparent
	mouse_filter = Control.MOUSE_FILTER_IGNORE
