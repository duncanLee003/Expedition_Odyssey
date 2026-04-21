extends Node

var scenes := {
	"Level1": "res://levels/level_1.tscn",
	"Level1pc": "res://levels/level1pcroom.tscn"
}

var fade: CanvasLayer

func transition_to_scene(level: String):
	var scene_path: String = scenes.get(level, "")
	if scene_path == "":
		push_error("Scene not found: " + level)
		return

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_physics_process(false)
		player.velocity = Vector2.ZERO

	# 🔥 STEP 1: fade OUT fully
	await Fade.fade_out(0.5)

	# 🔥 STEP 2: wait 1 frame so fade is actually drawn
	await get_tree().process_frame

	# 🔥 STEP 3: change scene
	get_tree().change_scene_to_file(scene_path)

	# 🔥 STEP 4: wait another frame (critical fix)
	await get_tree().process_frame

	# 🔥 STEP 5: fade IN
	await Fade.fade_in(0.5)
