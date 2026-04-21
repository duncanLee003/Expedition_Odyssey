extends Panel



@onready var inventory: Inventory = preload("res://inventory/playerInventory.tres")
@onready var slots: Array = $Container.get_children()
@onready var selector: Sprite2D = $Selector




var currently_selected: int = 0

func _ready():
	
	add_to_group("hotbar")
	update()
	inventory.updated.connect(update)
	for i in range(slots.size()):
		slots[i].index = i
		slots[i].slot_pressed.connect(select_slot)

func update() -> void:
	for i in range(slots.size()):
		var inventory_slot: InventorySlot = inventory.slots[i]
		slots[i].update_to_slot(inventory_slot)

func move_selector() -> void:
	currently_selected = (currently_selected + 1) % slots.size()
	selector.global_position = slots[currently_selected].global_position

func _unhandled_input(event) -> void:
	if event.is_action_pressed("use_item"):
		inventory.use_item_At_index(currently_selected)
	if event.is_action_pressed("move_selector"):
		move_selector()
	

func get_selected_item() -> InventoryItem:
	if currently_selected < 0 or currently_selected >= inventory.slots.size():
		return null
	
	return inventory.slots[currently_selected].item

func get_selected_index() -> int:
	return currently_selected

func select_slot(index: int) -> void:
	if slots.is_empty():
		return

	index = clamp(index, 0, slots.size() - 1)
	currently_selected = index

	var slot = slots[index]
	if !slot:
		return

	selector.global_position = slot.global_position
