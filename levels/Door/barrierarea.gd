extends Area2D


@onready var sprite = $"../Sprite2D"
@onready var barrier = $".."

@export var interact_cursor: Texture2D
@onready var cursor: Texture2D = preload("res://assets/normcursor.png")


@export var barrier_id: String = "barrier_1"

func is_opened() -> bool:
	return GameState.chest_states.get(barrier_id, false)
	
func _ready():
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	if is_opened():
		barrier.queue_free()

func _on_hover_enter():
	Input.set_custom_mouse_cursor(interact_cursor, Input.CURSOR_ARROW, Vector2(24, 24))
	
func _on_hover_exit():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(24, 24))

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_click()


func _on_click():
	var interaction_manager = get_tree().get_first_node_in_group("interaction_manager")

	
	var hotbar = get_tree().get_first_node_in_group("hotbar")
	if !hotbar:
		return
	

	var selected_item = hotbar.get_selected_item()
	if selected_item and selected_item.name == "key":
		print("unlock")
		barrier.queue_free()
		GameState.chest_states[barrier_id] = true
	
	if is_opened():
		if interaction_manager:
			interaction_manager.show_message("It's empty.")
		return  


		interaction_manager.show_message("It opened!")

		var index = hotbar.get_selected_index()
		hotbar.inventory.use_item_At_index(index)

	else:
	
		interaction_manager.show_message("It's locked.")


	
