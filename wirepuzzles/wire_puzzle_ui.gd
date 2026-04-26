extends Node2D

func open():
	show()
	#below is to pause game
	#get_tree().paused = true
	#process_mode = Node.PROCESS_MODE_ALWAYS

func close():
	hide()
	get_tree().paused = false

func _on_close_button_pressed():
	close()
