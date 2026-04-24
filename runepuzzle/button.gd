extends Sprite2D


func pressed():
	frame = 1
	
func unpressed():
	frame = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if !body.is_in_group("Player"):
		pressed()
		print ("ENTERED")


func _on_area_2d_body_exited(body: Node2D) -> void:
	unpressed()
	print("NOTENTERED")
