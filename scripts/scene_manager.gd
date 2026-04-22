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

	await Fade.fade_out(0.5)
	await get_tree().process_frame
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await Fade.fade_in(0.5)
