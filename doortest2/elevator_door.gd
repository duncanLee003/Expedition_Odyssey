extends Area2D

@export var next_scene: String
@export var interact_distance := 50.0
@export var door_id: String = "door_2"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow = $Arrow

var player: CharacterBody2D
var is_unlocked := false

var core = null


func _ready():
	player = get_tree().get_first_node_in_group("Player")

	# load saved state
	is_unlocked = GameState.door_states.get(door_id, false)
	
	if is_unlocked:
		apply_open_state()
	else:
		arrow.visible = false

	# find core and connect
	core = get_tree().get_first_node_in_group("core")
	if core:
		core.powered_on.connect(_on_core_powered)

	# if already unlocked (save system)
	if is_unlocked:
		anim.play("elevatorOpen")
		anim.frame = anim.sprite_frames.get_frame_count("elevatorOpen") - 1
	else:
		arrow.visible = false

func apply_open_state():
	anim.play("elevatorOpen")
	anim.frame = anim.sprite_frames.get_frame_count("elevatorOpen") - 1
# ----------------------------
# CORE SIGNAL
# ----------------------------
func _on_core_powered():
	if is_unlocked:
		return

	is_unlocked = true
	GameState.door_states[door_id] = true

	show_message("Power restored")

	await play_open_animation()


# ----------------------------
# INPUT
func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("CLICK DETECTED")
			try_enter()

func _input(event):
	if Input.is_action_just_pressed("enter_door"):
		try_enter()


# ----------------------------
# INTERACTION
# ----------------------------
func try_enter():

	print("TRY ENTER START")

	if !player:
		print("NO PLAYER FOUND")
		return

	var dist = player.global_position.distance_to(global_position)

	if dist > interact_distance:
		show_message("Too far away")
		return

	if !is_unlocked:
		show_message("No power...")
	else:
		enter_door()


# ----------------------------
# ANIMATION
# ----------------------------
func play_open_animation():
	if anim.animation == "open" and anim.frame == anim.sprite_frames.get_frame_count("open") - 1:
		return

	anim.play("elevatorOpen")
	await anim.animation_finished


# ----------------------------
# ENTER
# ----------------------------
func enter_door():



	SceneManager.transition_to_scene(next_scene)
# ----------------------------
# UI
# ----------------------------
func show_message(text):
	var im = get_tree().get_first_node_in_group("interaction_manager")
	if im:
		im.show_message(text)


func _process(delta):
	if !player:
		return

	if is_unlocked and player.global_position.distance_to(global_position) < interact_distance:
		arrow.visible = true
	else:
		arrow.visible = false
