extends Node2D


@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

@onready var locked_sound: AudioStreamPlayer2D = $LockedSound
@onready var open_sound: AudioStreamPlayer2D = $OpenSound

@export var required_item: InventoryItem

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	var hotbar = get_tree().get_first_node_in_group("hotbar")
	var interaction_manager = get_tree().get_first_node_in_group("interaction_manager")
	if !hotbar:
		return
	
	var selected_item = hotbar.get_selected_item()
	
	if selected_item and selected_item.name == "key":
		# Open chest
		sprite.frame = 1 if sprite.frame == 0 else 0
		open_sound.play()
		interaction_manager.show_message("It opened!")
		var index = hotbar.get_selected_index()
		hotbar.inventory.use_item_At_index(index)
	else:
		locked_sound.play()
		interaction_manager.show_message("It's locked.")
