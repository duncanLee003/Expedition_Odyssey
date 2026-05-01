extends Area2D

@onready var sprite = $"../Sprite2D"
@onready var locked_sound: AudioStreamPlayer2D = $"../LockedSound"
@onready var open_sound: AudioStreamPlayer2D = $"../OpenSound"

@export var interact_cursor: Texture2D
@onready var cursor: Texture2D = preload("res://assets/normcursor.png")

@export var chest_id: String = "chest_1"
@export var interact_distance := 50.0   # 👈 NEW

func is_opened() -> bool:
	return GameState.chest_states.get(chest_id, false)

func _ready():
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	
	if is_opened():
		sprite.frame = 1

func _on_hover_enter():
	Input.set_custom_mouse_cursor(interact_cursor, Input.CURSOR_ARROW, Vector2(24, 24))
	
func _on_hover_exit():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(24, 24))

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var player = get_tree().get_first_node_in_group("player")
		if !player:
			return
		
		var dist = player.global_position.distance_to(global_position)
		
		if dist > interact_distance:
			show_message("Too far away")
			return
		
		_on_click()

# -------------------------
# MAIN CHEST LOGIC
# -------------------------
func _on_click():
	var interaction_manager = get_tree().get_first_node_in_group("interaction_manager")

	var hotbar = get_tree().get_first_node_in_group("hotbar")
	if !hotbar:
		return
	
	if is_opened():
		if interaction_manager:
			interaction_manager.show_message("It's empty.")
		return  
	
	var selected_item = hotbar.get_selected_item()
	
	if selected_item and selected_item.name == "key":
		sprite.frame = 1
		open_sound.play()

		GameState.chest_states[chest_id] = true

		if interaction_manager:
			interaction_manager.show_message("It opened!")

		var index = hotbar.get_selected_index()
		hotbar.inventory.use_item_At_index(index)

	else:
		locked_sound.play()
		if interaction_manager:
			interaction_manager.show_message("It's locked.")

# -------------------------
# MESSAGE HELPER
# -------------------------
func show_message(text):
	var im = get_tree().get_first_node_in_group("interaction_manager")
	if im:
		im.show_message(text)
