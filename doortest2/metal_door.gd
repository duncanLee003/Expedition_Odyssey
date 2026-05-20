extends Area2D

@export var next_scene: String
@export var interact_distance := 50.0
@export var door_id: String = "door_1"
@onready var notification_icon = $"../CanvasLayer/JournalButton/NotificationJournal"
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow = $Arrow
var already_used := false
var player: CharacterBody2D
var is_unlocked := false

func _ready():

	
	is_unlocked = GameState.door_states.get(door_id, false)
	
	if is_unlocked:
	
		
		# set animation to final frame (open)
		anim.play("open")
		anim.frame = anim.sprite_frames.get_frame_count("open") - 1
	else:
		arrow.visible = false


func _input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.pressed:
		try_enter()


func _input(event):
	if Input.is_action_just_pressed("enter_door"):
		try_enter()


func try_enter():
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	var dist = player.global_position.distance_to(global_position)
	
	if dist > interact_distance:
		return
	
	if !is_unlocked:
		await try_unlock()
	else:
		enter_door()


func try_unlock():
	var hotbar = get_tree().get_first_node_in_group("hotbar")
	if !hotbar:
		return
	
	var selected_item = hotbar.get_selected_item()
	
	if selected_item and selected_item.name == "keycard":
		is_unlocked = true
		
		GameState.door_states[door_id] = true  
		

		

		
		show_message("Door unlocked")
		
		await play_open_animation()
	else:
		show_message("It's locked")
		
		if already_used:
			return
		already_used = true
		GameState.current_quest = "find_key"
		notification_icon.visible = true
		
		var journal = get_tree().get_first_node_in_group("journal_update")

		if journal:
			journal.show_update()
			


func play_open_animation():
	# prevent replay if already open
	if anim.animation == "open" and anim.frame == anim.sprite_frames.get_frame_count("open") - 1:
		return
	
	anim.play("open")
	await anim.animation_finished


func enter_door():
	
	SceneManager.transition_to_scene(next_scene)


func show_message(text):

	var dialogue = get_tree().get_first_node_in_group("dialogue_ui")

	if dialogue:
		dialogue.show_message(text) 
		
func _process(delta):
	if !player:
		return
	
	if is_unlocked and player.global_position.distance_to(global_position) < interact_distance:
		arrow.visible = true
	else:
		arrow.visible = false
