extends Node2D


@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

@export var required_item: InventoryItem

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	var hotbar = get_tree().get_first_node_in_group("hotbar")
	if !hotbar:
		return
	
	var selected_item = hotbar.get_selected_item()
	
	if selected_item and selected_item.name == "key":
		# Open chest
		sprite.frame = 1 if sprite.frame == 0 else 0
	else:
		print("You need the correct key!")
