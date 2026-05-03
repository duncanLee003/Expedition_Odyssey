extends Node2D

func open():
	show()


func close():
	hide()
	get_tree().paused = false

func _on_close_button_pressed():
	close()
