extends Node

var puzzle_failed_state := false
@onready var barrier = get_tree().get_first_node_in_group("barrier")

# ----------------------------
# PUZZLE SETUP
# ----------------------------
var correct_order: Array[String] = [
	"plate_1",
	"plate_2",
	"plate_3",
	"plate_2",
	"plate_1",
	"plate_2",
	"plate_4",
	"plate_1"
]

var current_index: int = 0

# plate_id -> light node
var lights: Dictionary = {}


# ----------------------------
# SIGNALS
# ----------------------------
signal puzzle_completed
signal puzzle_reset


# ----------------------------
# REGISTER LIGHTS
# ----------------------------
func register_light(plate_id: String, light_node):

	lights[plate_id] = light_node


# ----------------------------
# PRESS PLATE (MAIN LOGIC)
# ----------------------------
func press_plate(plate_id: String):

	# LOCK puzzle after wrong input
	if puzzle_failed_state:

		return


	if current_index >= correct_order.size():
		return


	# ALWAYS give neutral feedback (no information leak)
	if lights.has(plate_id):
		flash_neutral(lights[plate_id])

	# correct step (hidden logic)
	if plate_id == correct_order[current_index]:

		current_index += 1



		if current_index == correct_order.size():
	
			puzzle_completed.emit()

			open_barrier()
			var interaction_manager = get_tree().get_first_node_in_group("interaction_manager")


			if interaction_manager:
						interaction_manager.show_message("The door opened.")

	# wrong step (still hidden from player)
	else:


		puzzle_failed_state = true


# ----------------------------
# PLAYER LEAVES PLATE (optional visual reset)
# ----------------------------
func release_plate(plate_id: String):

	if lights.has(plate_id):
		reset_light(lights[plate_id])


# ----------------------------
# RESET PUZZLE (NO VISUAL CLUES)
# ----------------------------
func reset_puzzle():



	current_index = 0
	puzzle_failed_state = false

	flash_all_reset()

	for id in lights.keys():
		reset_light(lights[id])


	puzzle_reset.emit()
	var interaction_manager = get_tree().get_first_node_in_group("interaction_manager")


	if interaction_manager:
				interaction_manager.show_message("You reset the puzzle.")


# ----------------------------
# FAILURE (HIDDEN FROM PLAYER)
# ----------------------------
func puzzle_failed():


	current_index = 0

	for id in lights.keys():
		reset_light(lights[id])

	puzzle_reset.emit()


# ----------------------------
# VISUAL FEEDBACK (NEUTRAL ONLY)
# ----------------------------
func flash_neutral(light):

	if light == null:
		return

	var tween = create_tween()

	# stronger visible flash
	tween.tween_property(light, "modulate", Color(2.5, 2.5, 2.5), 0.1)
	tween.tween_property(light, "modulate", Color.WHITE, 0.25)

func reset_light(light):

	if light == null:
		return

	var tween = create_tween()

	tween.tween_property(light, "modulate", Color.WHITE, 0.2)

func flash_all_reset():

	for id in lights.keys():
		var light = lights[id]
		if light == null:
			continue

		var tween = create_tween()

		# strong reset flash
		tween.tween_property(light, "modulate", Color(2.2, 2.2, 2.2), 0.08)
		tween.tween_property(light, "modulate", Color.WHITE, 0.2)

func open_barrier():

	if !barrier:
		return

	var tween = create_tween()

	# move barrier up
	tween.tween_property(barrier, "position", barrier.position + Vector2(0, -200), 1.0)

	# disable collision after movement
	tween.tween_callback(func():
		if barrier.has_node("CollisionShape2D"):
			barrier.get_node("CollisionShape2D").disabled = true
	)
