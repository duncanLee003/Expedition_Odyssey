extends Node2D

@onready var wire_layer = $"../Wires"

signal puzzle_completed

@export var required_wires := ["A", "B", "C", "D", "E", "F", "G"]

var puzzle_solved := false

var active_line: Line2D = null
var start_pin = null
var wire_locked := false

var completed_wires := {}
var locked_lines := []

var damage_cooldown := false


func _ready():
	add_to_group("wire_manager")

	# FULL RESET ON RE-ENTER (THIS IS THE KEY FIX)
	puzzle_solved = false
	active_line = null
	start_pin = null
	wire_locked = false
	completed_wires.clear()
	locked_lines.clear()


func start_wire(pin):

	if puzzle_solved:
		return

	if active_line != null:
		cancel_wire()

	if completed_wires.has(pin.wire_id):
		return

	start_pin = pin
	wire_locked = false

	active_line = Line2D.new()
	active_line.width = 6
	active_line.default_color = Color.WHITE
	active_line.z_index = 100

	wire_layer.add_child(active_line)

	var local_pos = wire_layer.to_local(pin.global_position)

	active_line.add_point(local_pos)
	active_line.add_point(local_pos)


func _process(_delta):

	if active_line and not wire_locked:

		var mouse_local = wire_layer.to_local(get_global_mouse_position())
		active_line.set_point_position(1, mouse_local)


func end_wire(pin):

	if puzzle_solved:
		return

	if active_line == null or start_pin == null:
		cancel_wire()
		return

	if pin == start_pin:
		cancel_wire()
		return

	# CORRECT
	if pin.wire_id == start_pin.wire_id:

		active_line.set_point_position(
			1,
			wire_layer.to_local(pin.global_position)
		)

		wire_locked = true
		completed_wires[start_pin.wire_id] = true

		locked_lines.append(active_line)

		active_line = null
		start_pin = null

		check_win()
		return

	# WRONG
	if not damage_cooldown:

		damage_cooldown = true

		var player = get_tree().get_first_node_in_group("player")

		if player and player.has_method("take_damage"):
			player.take_damage(10, player.DamageSource.WIRE)

		cancel_wire()

		await get_tree().create_timer(0.5).timeout
		damage_cooldown = false


func cancel_wire():

	if active_line:
		active_line.queue_free()

	active_line = null
	start_pin = null
	wire_locked = false


func check_win():

	if puzzle_solved:
		return

	for id in required_wires:
		if not completed_wires.has(id):
			return

	puzzle_solved = true
	set_process(false)

	puzzle_completed.emit()

	show_message("Power restored")

	await get_tree().create_timer(0.3).timeout

	var ui = get_tree().get_first_node_in_group("wire_puzzle_ui")

	if ui:
		ui.close()
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("GLOBAL CLICK:", event.position)

func show_message(text: String):

	var ui = get_tree().get_first_node_in_group("dialogue_ui")

	if ui:
		ui.show_message(text)
