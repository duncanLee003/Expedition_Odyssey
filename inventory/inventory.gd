extends Resource

class_name Inventory


signal updated

@export var slots: Array[InventorySlot]


func insert(item: InventoryItem):
	for slot in slots:
		if slot.item == item:
			slot.amount += 1
			updated.emit()
			return
	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			updated.emit()
			return
	updated.emit()

func removeItemAtIndex(index: int):
	slots[index] = InventorySlot.new()
	updated.emit()
	


func insertSlot(index: int, inventorySlot:InventorySlot):
	var oldIndex: int = slots.find(inventorySlot)
	removeItemAtIndex(oldIndex)
	
	slots[index] = inventorySlot
	updated.emit()

func use_item_At_index(index: int) -> void:
	if index < 0 || index >= slots.size() || !slots[index].item: return
	
	var slot = slots[index]
	
	if slot.amount > 1:
		slot.amount -= 1
		updated.emit()
		return
	
	removeItemAtIndex(index)
