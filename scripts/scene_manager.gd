extends Node

var scenes := {
	"Level1": "res://levels/level_1.tscn",
	"Level1pc": "res://levels/level1pcroom.tscn",
	"TLevel1": "res://levels/truelevel_1.tscn",
	"artifactLevel1": "res://levels/artifactlevel_1.tscn",
	"TLevel2": "res://levels/truelevel_2.tscn",
	"NPCroom": "res://npcs/npc_room.tscn"
}

var fade: CanvasLayer

func transition_to_scene(level: String):

	get_tree().paused = false

	var scene_path: String = scenes.get(level, "")

	if scene_path == "":
		push_error("Scene not found: " + level)
		return

	var player = get_tree().get_first_node_in_group("player")

	if player:
		var current_scene = get_tree().current_scene.scene_file_path
		GameState.scene_player_positions[current_scene] = player.global_position

		player.set_physics_process(false)
		player.velocity = Vector2.ZERO

	await Fade.fade_out(0.5)

	await get_tree().process_frame

	get_tree().change_scene_to_file(scene_path)

	get_tree().paused = false

	await get_tree().process_frame
	await get_tree().process_frame

	await Fade.fade_in(0.5)
