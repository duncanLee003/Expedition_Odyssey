extends CharacterBody2D

@export var speed : int = 150
@export var wait_time : float = 2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer


const GRAVITY = 1000

enum State { Idle, Walk }
var current_state : State = State.Idle

var direction : Vector2 = Vector2.LEFT
var can_walk : bool = true

func _ready():
	timer.wait_time = wait_time
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float):
	apply_gravity(delta)
	handle_movement(delta)
	move_and_slide()
	update_animation()

func apply_gravity(delta: float):
	velocity.y += GRAVITY * delta

func handle_movement(delta: float):
	if can_walk:
		velocity.x = direction.x * speed
		current_state = State.Walk
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle

	animated_sprite_2d.flip_h = direction.x > 0

func update_animation():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk:
		animated_sprite_2d.play("walk")

func _on_timer_timeout():
	# Flip direction
	direction *= -1
	
	# Start walking again
	can_walk = true

func stop_and_turn():
	can_walk = false
	timer.start()
	
