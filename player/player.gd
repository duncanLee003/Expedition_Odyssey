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
var health_bar
var is_on_ladder := false
var climb_speed := 150.0
@onready var damage_flash = get_tree().get_first_node_in_group("damage_flash")

enum State {Idle, Run, Jump, Shoot}

var current_state: State
var character_sprite : Sprite2D

var muzzle_position := Vector2.ZERO


enum DamageSource {
	ENEMY,
	WIRE
}


func _process(_delta):
	if hotbar == null:
		hotbar = get_tree().get_first_node_in_group("hotbar")
func _ready():
	await get_tree().process_frame
	hotbar = get_tree().get_first_node_in_group("hotbar")
	health_bar = get_tree().get_first_node_in_group("health_bar")
	add_to_group("player")
	add_to_group("activator")
	current_state = State.Idle
	if muzzle:
		muzzle_position = muzzle.position
	current_health = max_health	
	update_health_ui()
	process_mode = Node.PROCESS_MODE_ALWAYS


	var scene_path = get_tree().current_scene.scene_file_path

	if GameState.scene_player_positions.has(scene_path):
		global_position = GameState.scene_player_positions[scene_path]
	



func _physics_process(delta : float):
	if !is_inside_tree():
		return

	if !muzzle:
		return
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	player_muzzle_position()
	player_shooting(delta)
	if is_on_ladder:

		velocity.y = 0

		if Input.is_action_pressed("climb_up"):
			velocity.y = -climb_speed

		elif Input.is_action_pressed("climb_down"):
			velocity.y = climb_speed
	
	move_and_slide()

	
	player_animations()
	
	print("State: ", State.keys()[current_state])
	
	
func player_falling(delta : float):

	if is_on_ladder:
		return

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

	if !muzzle:
		return Vector2.RIGHT

	var mouse_pos = get_global_mouse_position()

	return (mouse_pos - muzzle.global_position).normalized()

func player_shooting(delta: float):

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

	if !muzzle:
		return

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

func take_damage(amount: int, source := DamageSource.ENEMY):

	current_health -= amount
	current_health = clamp(current_health, 0, max_health)

	update_health_ui()

	screen_shake(3)

	# screen effect (subtle, safe)
	match source:
		DamageSource.ENEMY:
			play_damage_flash(Color(1, 0, 0))
		DamageSource.WIRE:
			play_damage_flash(Color(0.2, 0.8, 1))

	# ⭐ player sprite flash (always red for clarity)
	play_player_damage_flash()

	if current_health <= 0:
		die()

func screen_shake(intensity := 5.0):
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return

	var original_pos = camera.position

	var tween = create_tween()

	for i in range(6):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)

		tween.tween_property(camera, "position", original_pos + offset, 0.03)

	tween.tween_property(camera, "position", original_pos, 0.05)

func die():
	var death_screen = get_tree().get_first_node_in_group("death_screen")
	
	if death_screen:
		death_screen.show_death_screen()
	
	queue_free()

func play_player_damage_flash():
	if animated_sprite_2d == null:
		return

	# quick red tint
	animated_sprite_2d.modulate = Color(1, 0.3, 0.3, 1)

	await get_tree().create_timer(0.12).timeout

	animated_sprite_2d.modulate = Color.WHITE
	
func update_health_ui():
	if health_bar == null:
		return
	
	health_bar.max_value = max_health
	health_bar.value = current_health
	

func play_damage_flash(color: Color):
	if damage_flash == null:
		return

	damage_flash.visible = true

	# always start clean
	damage_flash.color = Color(0, 0, 0, 0)

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	# ⚠️ very subtle flash (low alpha)
	tween.tween_property(
		damage_flash,
		"color",
		Color(color.r, color.g, color.b, 0.12),
		0.04
	)

	# fade back quickly (no lingering tint)
	tween.tween_property(
		damage_flash,
		"color",
		Color(0, 0, 0, 0),
		0.18
	)

func _on_inventory_gui_closed() -> void:
	get_tree().paused = false


func _on_inventory_gui_opened() -> void:
	get_tree().paused = true
