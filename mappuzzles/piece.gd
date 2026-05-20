extends TextureRect

var locked := false
var dragging := false
var drag_offset := Vector2.ZERO

func get_map_ui():
	return get_tree().get_first_node_in_group("map_puzzle")

func _ready():
	add_to_group("map_pieces")

	mouse_filter = Control.MOUSE_FILTER_STOP

	if GameState.map_completed:
		queue_free()


func _gui_input(event):


	if locked:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
		else:
			dragging = false


# -------------------------
# DRAG UPDATE
# -------------------------
func _process(_delta):

	if dragging:
		global_position = get_global_mouse_position() + drag_offset
		check_snap()


# -------------------------
# SNAP LOGIC
# -------------------------
func check_snap():

	for zone in get_tree().get_nodes_in_group("snap_zones"):

		var rect = zone.get_global_rect()

		if rect.grow(10).has_point(global_position):

			if zone.is_correct(name):
				snap_to_zone(zone)
				return


func snap_to_zone(zone):

	if locked:
		return

	dragging = false
	locked = true

	var snap_point = zone.get_node("SnapPoint")

	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		snap_point.global_position,
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var ui = get_map_ui()
	if ui:
		ui.check_complete()
