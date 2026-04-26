extends Node2D

@onready var wire_layer = $"../Wires"

@export var required_wires := ["A", "B"]

var active_line: Line2D = null
var start_pin = null

var wire_locked := false
var completed_wires := {}

# -------------------------------------------------
# SETUP SIGNALS
# -------------------------------------------------
func _ready():
	await get_tree().process_frame

	for pin in get_tree().get_nodes_in_group("pins"):
		pin.clicked.connect(start_wire)
		pin.released.connect(end_wire)

	print("WireManager ready. Pins found:", get_tree().get_nodes_in_group("pins").size())


# -------------------------------------------------
# START WIRE (mouse down on pin)
# -------------------------------------------------
func start_wire(pin):
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

	print("START WIRE:", pin.name)


# -------------------------------------------------
# UPDATE WIRE (follow mouse)
# -------------------------------------------------
func _process(delta):
	if active_line and not wire_locked:
		var mouse_local = wire_layer.to_local(get_global_mouse_position())
		active_line.set_point_position(1, mouse_local)


# -------------------------------------------------
# END WIRE (mouse released on pin)
# -------------------------------------------------
func end_wire(pin):
	if active_line == null or start_pin == null:
		return

	if pin == start_pin:
		cancel_wire()
		return

	# -------------------------------------------------
	# CORRECT CONNECTION
	# -------------------------------------------------
	if pin.wire_id == start_pin.wire_id:

		active_line.set_point_position(
			1,
			wire_layer.to_local(pin.global_position)
		)

		wire_locked = true

		completed_wires[start_pin.wire_id] = true

		print("CONNECTED:", start_pin.wire_id)

		check_win()

	else:
		cancel_wire()

	active_line = null
	start_pin = null


# -------------------------------------------------
# CANCEL WRONG WIRE
# -------------------------------------------------
func cancel_wire():
	if active_line:
		active_line.queue_free()

	active_line = null
	start_pin = null


# -------------------------------------------------
# WIN CHECK
# -------------------------------------------------
func check_win():
	for id in required_wires:
		if not completed_wires.has(id):
			return

	print("PUZZLE COMPLETE!")


func _on_close_button_pressed() -> void:
	hide()
	get_tree().paused = false
