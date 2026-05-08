extends Control

@export var correct_piece_name: String

func is_correct(piece_name):
	return piece_name == correct_piece_name
