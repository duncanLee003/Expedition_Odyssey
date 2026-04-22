extends Control

signal opened
signal closed


var isOpen: bool = false

@onready var inventory: Inventory = preload("res://inventory/playerInventory.tres")
@onready var ItemStackGuiClass = preload("res://collectables/itemsStackGui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var hotbar = null

var itemInHand: ItemStackGui

func _ready():
	await get_tree().process_frame
	hotbar = get_tree().get_first_node_in_group("hotbar")
	connectSlots()
	inventory.updated.connect(update)
	update()
	
	
func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item:
			slots[i].clear()
			continue
		
		var itemStackGui: ItemStackGui = slots[i].itemStackGui
		if !itemStackGui:
			itemStackGui = ItemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)
			
		itemStackGui.inventorySlot = inventorySlot
		itemStackGui.update()

func open():
	visible = true
	isOpen = true
	opened.emit()

func close():
	visible = false
	isOpen = false
	closed.emit()
	


func onSlotClicked(slot):
	var index = slot.index
	
	
	#move selection in hotbar
	hotbar.select_slot(index)
	
	if slot.isEmpty():
		if !itemInHand: return
		
		insertItemInSlot(slot)
		return
	
	if!itemInHand:
		takeItemFromSlot(slot)
		return
	
	if slot.itemStackGui.inventorySlot.item.name == itemInHand.inventorySlot.item.name:
		stackItems(slot)
		return
	
	swapItems(slot)
	
func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()

func insertItemInSlot(slot):
	if !itemInHand:
		return

	var item = itemInHand

	remove_child(itemInHand)
	itemInHand = null

	#updates if slot changing
	if slot.itemStackGui == item:
		return

	slot.insert(item)
	
func swapItems(slot):
	var tempItem = slot.takeItem()
	
	insertItemInSlot(slot)
	
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()
	
func stackItems(slot):
	var slotItem: ItemStackGui = slot.itemStackGui
	var maxAmount = slotItem.inventorySlot.item.max_amount_per_stack
	var totalAmount  = slotItem.inventorySlot.amount + itemInHand.inventorySlot.amount
	
	if slotItem.inventorySlot.amount == maxAmount:
		swapItems(slot)
		return
	slotItem.update()
	if itemInHand: itemInHand.update()
	
	

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func _input(event):
	updateItemInHand()
	
func _process(_delta):
	if Input.is_action_just_pressed ("toggle_inventory"):
		var ciljaniSlot
		if !isOpen: 
			if itemInHand: 
				for i in range(slots.size()):
					var slot = slots[i]
					if slot.isEmpty():
						ciljaniSlot = slot
						break
				onSlotClicked(ciljaniSlot)
			close()
		else:
			open()
