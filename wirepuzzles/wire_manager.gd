extends Node2D

@onready var wire_layer = $"../Wires"
var puzzle_solved := false
@export var required_wires := ["A", "B", "C", "D", "E", "F", "G"]

var active_line: Line2D = null
var start_pin = null

var wire_locked := false
var completed_wires := {}

func can_connect() -> bool:
	return GameState.wires_collected >= GameState.wires_required

signal puzzle_completed
var damage_cooldown := false

var locked_lines: Array = []

func _ready():
	add_to_group("wire_manager")
	await get_tree().process_frame

	for pin in get_tree().get_nodes_in_group("pins"):
		pin.clicked.connect(start_wire)
		pin.released.connect(end_wire)

	print("WireManager ready. Pins found:", get_tree().get_nodes_in_group("pins").size())


func start_wire(pin):

	if active_line != null:
		cancel_wire()

	if !can_connect():
		show_message("You need more wires")
		return

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



func _process(delta):
	if active_line and not wire_locked:
		var mouse_local = wire_layer.to_local(get_global_mouse_position())
		active_line.set_point_position(1, mouse_local)



func end_wire(pin):

	
	

	if active_line == null or start_pin == null:
		cancel_wire()
		return

	if pin == start_pin:
		cancel_wire()
		return

	if pin.wire_id == start_pin.wire_id:

		active_line.set_point_position(
			1,
			wire_layer.to_local(pin.global_position)
		)

		wire_locked = true

		completed_wires[start_pin.wire_id] = true

		# ✅ IMPORTANT: LOCK THE LINE
		locked_lines.append(active_line)

		active_line = null
		start_pin = null

		check_win()
		return

	else:

		if not damage_cooldown:

			damage_cooldown = true

			var player = get_tree().get_first_node_in_group("player")

			if player and player.has_method("take_damage"):
				player.take_damage(10, player.DamageSource.WIRE)
				var fx = get_tree().get_first_node_in_group("electric_fx")
				if fx:
					fx.play()

			await get_tree().create_timer(0.5).timeout
			damage_cooldown = false

		cancel_wire()


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

	print("PUZZLE COMPLETE!")

	puzzle_completed.emit()

	var hotbar = get_tree().get_first_node_in_group("hotbar")

	if hotbar:
		var inventory = hotbar.inventory
		inventory.remove_item_by_name(
			"scrap",
			GameState.wires_required
		)

	# success message
	show_message("Power restored")

	# wait briefly
	await get_tree().create_timer(1.0, true).timeout

	# close UI
	var ui = get_tree().get_first_node_in_group("wire_puzzle_ui")

	if ui:
		ui.close()



func _on_close_button_pressed() -> void:
	hide()
	get_tree().paused = false

func show_message(text):
	var im = get_tree().get_first_node_in_group("interaction_manager")
	if im:
		im.show_message(text)
