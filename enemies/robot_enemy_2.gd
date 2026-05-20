extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("Player")
@export var chase_range: float = 200.0
var damage_flash := false
@onready var patrol_points = $PatrolPoints

@export var wait_time : int = 3
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var speed : float = 100.0
@export var chase_speed : float = 100.0
@export var max_health := 50
var current_health := 50

@export var respawn_distance := 800.0
@export var respawn_time := 5.0

var spawn_position : Vector2
var is_dead := false

var can_attack := true


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

const GRAVITY = 1000


enum State { Idle, Walk, Chase, Attack }
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool

func _ready():
	add_to_group("enemy")
	current_health = max_health
	spawn_position = global_position
	if patrol_points == null:
	
		return
	
	for point in patrol_points.get_children():
		point_positions.append(point.global_position)
	
	number_of_points = point_positions.size()
	
	if number_of_points == 0:
	
		return
	
	current_point = point_positions[0]
	
	timer.wait_time = wait_time
	
	can_walk = true
	current_state = State.Idle
	
func _physics_process(delta : float):
	enemy_gravity(delta)
	
	if player_in_range():
		enemy_chase(delta)
	else:
		enemy_idle(delta)
		enemy_walk(delta)
	
	move_and_slide()
	
	enemy_animations()
	
func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta : float):
	if !can_walk:
		velocity.x = move_toward (velocity.x, 0, speed * delta)
		current_state = State.Idle
func enemy_walk(delta : float):
	if !can_walk:
		return
	
	# decide direction first
	if current_point.x > global_position.x:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	
	animated_sprite_2d.flip_h = direction.x < 0
	
	# move toward point
	if abs(global_position.x - current_point.x) > 5:
		velocity.x = direction.x * speed
		current_state = State.Walk
	else:
		velocity.x = 0
		current_state = State.Idle
		
		current_point_position += 1
		
		if current_point_position >= number_of_points:
			current_point_position = 0
		
		current_point = point_positions[current_point_position]
		
		can_walk = false
		timer.start()
func enemy_animations():
	match current_state:
		State.Idle:
			animated_sprite_2d.play("robot_idle")
			
		State.Walk:
			animated_sprite_2d.play("robot_walk")
			
		State.Chase:
			animated_sprite_2d.play("robot_walk")
			
		State.Attack:
			animated_sprite_2d.play("robot_attack")

func _on_timer_timeout() -> void:
	can_walk = true

func player_in_range() -> bool:
	if player == null:
		return false
	
	return global_position.distance_to(player.global_position) <= chase_range
func enemy_chase(delta):
	if player == null:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	# face player
	if player.global_position.x > global_position.x:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	
	animated_sprite_2d.flip_h = direction.x < 0
	
	# attack
	if distance <= attack_range:
		current_state = State.Attack
		velocity.x = 0
		
		if can_attack:
			can_attack = false
			
			animated_sprite_2d.play("robot_attack")

			await get_tree().create_timer(0.3).timeout

			player.take_damage(10, player.DamageSource.ENEMY)

			
		
			
			await get_tree().create_timer(attack_cooldown).timeout
			
			can_attack = true
		
		return
	
	# chase
	current_state = State.Chase
	velocity.x = direction.x * chase_speed


func take_damage(amount: int):

	if damage_flash:
		return

	damage_flash = true

	current_health -= amount



	# flash red
	animated_sprite_2d.modulate = Color(1, 0, 0, 0.7)

	await get_tree().create_timer(0.15).timeout

	animated_sprite_2d.modulate = Color.WHITE

	damage_flash = false

	if current_health <= 0:
		die()

func die():
	is_dead = true
	
	visible = false
	set_physics_process(false)
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	respawn_enemy()

func respawn_enemy():
	current_point_position = 0
	current_point = point_positions[0]
	can_walk = true
	await get_tree().create_timer(respawn_time).timeout
	
	# wait until player is far enough
	while player and global_position.distance_to(player.global_position) < respawn_distance:
		await get_tree().process_frame
	
	# reset enemy
	current_health = max_health
	global_position = spawn_position
	
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	
	is_dead = false
	set_physics_process(true)
