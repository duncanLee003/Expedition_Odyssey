extends CanvasLayer

@onready var inventory = $InventoryGui


func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	inventory.close()



func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()
