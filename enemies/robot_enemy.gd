extends CharacterBody2D

const GRAVITY = 20

@export var speed: float = 100.0
@export var damage: int = 10
@export var attack_range: float = 35.0
@onready var attack_area = $AttackArea
@onready var robot_collision = $RobotCollision
@onready var point_a = $PointA
@onready var point_b = $PointB

var moving_to_b = true
@export var detection_range: float = 150.0

var patrol_target

var player = null
var is_attacking = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer


func _ready():
	player = get_tree().get_first_node_in_group("player")
	patrol_target = point_b

func _physics_process(delta):

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	# gravity
	if !is_on_floor():
		velocity.y += GRAVITY

	var distance = global_position.distance_to(player.global_position)

	# =====================
	# 1. ATTACK (highest priority)
	# =====================
	if distance <= attack_range:
		velocity.x = 0

		if attack_timer.is_stopped():
			attack()

	# =====================
	# 2. CHASE
	# =====================
	elif distance <= detection_range:
		var direction = sign(player.global_position.x - global_position.x)

		velocity.x = direction * speed
		animated_sprite.flip_h = direction < 0

		if animated_sprite.animation != "robot_walk":
			animated_sprite.play("robot_walk")

	# =====================
	# 3. PATROL (ONLY when idle)
	# =====================
	else:
		patrol()

	move_and_slide()

func attack():

	is_attacking = true

	velocity.x = 0

	# windup
	await get_tree().create_timer(0.3).timeout

	animated_sprite.play("robot_attack")

	# enable hitbox DURING swing
	attack_area.monitoring = true

	# active slash frames
	await get_tree().create_timer(0.2).timeout

	# disable hitbox
	attack_area.monitoring = false

	attack_timer.start()

	await animated_sprite.animation_finished

	is_attacking = false

func _on_attack_area_body_entered(body):

	if body.is_in_group("player"):
		body.take_damage(damage)

func patrol():

	var target_x = point_b.global_position.x if moving_to_b else point_a.global_position.x

	var direction = sign(target_x - global_position.x)

	velocity.x = direction * speed

	if direction != 0:
		animated_sprite.flip_h = direction < 0

	if animated_sprite.animation != "robot_walk":
		animated_sprite.play("robot_walk")

	if abs(global_position.x - target_x) < 5:
		moving_to_b = !moving_to_b
