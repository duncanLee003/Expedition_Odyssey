extends CharacterBody2D

var bullet = preload("res://player/bullet.tscn")
var has_blaster: bool = false
@export var fire_rate: float = 0.2 # seconds between shots
var shoot_timer: float = 0.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle : Marker2D = $Muzzle
@export var blaster_item: InventoryItem
var hotbar: Node = null

const GRAVITY = 20
@export var speed : int = 230
@export  var jump : int = -400
@export  var jump_horizontal : int = 100

@export var inventory: Inventory
@export var max_health: int = 100
var current_health: int
@onready var health_bar = $"../CanvasLayer/HealthBar"

enum State {Idle, Run, Jump, Shoot}

var current_state: State
var character_sprite : Sprite2D

var muzzle_position
func _process(_delta):
	if hotbar == null:
		hotbar = get_tree().get_first_node_in_group("hotbar")
func _ready():
	await get_tree().process_frame
	hotbar = get_tree().get_first_node_in_group("hotbar")
	add_to_group("player")
	add_to_group("activator")
	current_state = State.Idle
	muzzle_position = muzzle.position
	current_health = max_health	
	update_health_ui()



func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	player_muzzle_position()
	player_shooting(delta)
	
	
	move_and_slide()

	
	player_animations()
	
	print("State: ", State.keys()[current_state])
	
func player_falling(delta : float):
	if !is_on_floor():
		velocity.y += GRAVITY + delta
		
@warning_ignore("unused_parameter")
func player_idle(delta : float):
	if is_on_floor():
		current_state = State.Idle
		
		


func player_run(delta : float):
	var direction = input_movement()
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction != 0:
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction > 0 else true

func player_jump(float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = State.Jump
		
	if !is_on_floor() and current_state == State.Jump:
		var direction = input_movement()
		velocity.x += direction * jump_horizontal

func get_aim_direction() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	return (mouse_pos - muzzle.global_position).normalized()
func player_shooting(delta: float):
	print("---- SHOOT DEBUG ----")
	print("hotbar:", hotbar)
	print("selected:", hotbar.get_selected_item() if hotbar else null)
	print("mouse:", Input.is_action_pressed("shoot"))
	print("timer:", shoot_timer)
	if hotbar == null:
		return

	var selected_item = hotbar.get_selected_item()
	if !selected_item:
		return

	if selected_item.id != "blaster":
		return

	shoot_timer -= delta

	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot_timer = fire_rate
		current_state = State.Shoot
		var aim_dir = get_aim_direction()

		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = aim_dir
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
	
func player_muzzle_position():
	var direction = input_movement()
	
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x

func player_animations():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run and is_on_floor() and animated_sprite_2d.animation != "run_shoot":
		animated_sprite_2d.play("run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")
	elif current_state == State.Shoot:
		animated_sprite_2d.play("run_shoot")

func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	
	return direction

func take_damage(amount: int):

	current_health -= amount

	current_health = clamp(current_health, 0, max_health)

	print("Player Health: ", current_health)


	update_health_ui()

	if current_health <= 0:
		die()

func die():
	queue_free() # or reload scene, play animation, etc.

func update_health_ui():

	health_bar.max_value = max_health
	health_bar.value = current_health
	
	


func _on_inventory_gui_closed() -> void:
	get_tree().paused = false


func _on_inventory_gui_opened() -> void:
	get_tree().paused = true
