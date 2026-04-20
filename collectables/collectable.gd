extends Area2D

@export var itemRes: InventoryItem

func _ready():
	input_pickable = true  # IMPORTANT for clicking


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			collect(player.inventory)


func collect(inventory: Inventory):
	inventory.insert(itemRes)
	queue_free()
