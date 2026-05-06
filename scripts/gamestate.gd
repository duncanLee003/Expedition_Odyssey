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
