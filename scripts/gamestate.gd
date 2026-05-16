extends Node

#store states across world levels
var chest_states: Dictionary = {}
var door_states: Dictionary = {}
var core_powered := false
var green_filter_enabled := false

var wires_collected := 0
var wires_required := 7

var map_completed := false
var map_piece_states := {}
var journal_page := "inventory"

var current_quest := "none"
var usb_inserted := false
var robot_password_learned := false
var security_unlocked := false
var robot_activated := false
var scene_player_positions := {}
var lasers_disabled := false
signal security_unlocked_changed
var security_terminal_seen := false
var journal_tutorial_seen := false

var collected_map_pieces := 0
var map_puzzle_unlocked := false
var box_positions := {}
var collected_items := {}
