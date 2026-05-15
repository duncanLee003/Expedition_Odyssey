extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://inventory/playerInventory.tres")
@onready var ItemStackGuiClass = preload("res://collectables/itemsStackGui.tscn")
@onready var slots: Array = $NinePatchRect/inventory_page/GridContainer.get_children()
@onready var hotbar = null
@onready var map_image = $NinePatchRect/info_page/MapImage
@onready var map_puzzle = get_tree().get_first_node_in_group("map_puzzle")
@onready var notification_icon = $"../JournalButton/NotificationJournal"
@onready var usb_image = $NinePatchRect/info_page/USBImage
@onready var password_image = $NinePatchRect/info_page/PasswordImage
@onready var description_box = $NinePatchRect/inventory_page/DescriptionBox
@onready var description_label = $NinePatchRect/inventory_page/DescriptionBox/Label

var itemInHand: ItemStackGui

# ----------------------------
# PAGES
# ----------------------------
@onready var inventory_page = $NinePatchRect/inventory_page
@onready var settings_page = $NinePatchRect/settings_page
@onready var quest_page = $NinePatchRect/quest_page
@onready var info_page = $NinePatchRect/info_page

# ----------------------------
# BOOKMARK BUTTONS
# ----------------------------
@onready var inventory_button = $inventory_button
@onready var settings_button = $settings_button
@onready var quest_button = $quest_button
@onready var info_button = $info_button

var buttons = []
var selected_button = null
var button_base_positions = {}

var tutorial_lines = [
	"Inventory [pink] stores your items.           Click on the [red label]",
	"Settings [red] shows the menu.          Click on the [green label]",
	"Quests [green] tracks your objectives.           Click on the [blue label]",
	"Info [blue] stores clues and your discoveries."
]

var tutorial_index := 0
var tutorial_active := false

@onready var tutorial_panel = $TutorialPanel
@onready var tutorial_label = $TutorialPanel/Label

func _ready():
	Journal.updated.connect(update_journal)
	update_journal()
	if map_puzzle:
		map_puzzle.map_completed.connect(_on_map_completed)

	# restore state
	if GameState.map_completed:
		show_map()
	
	await get_tree().process_frame


	hotbar = get_tree().get_first_node_in_group("hotbar")

	# setup slots
	connectSlots()
	inventory.updated.connect(update)
	update()

	# setup buttons
	buttons = [
		inventory_button,
		settings_button,
		quest_button,
		info_button
	]
	for b in buttons:
		button_base_positions[b] = b.position
	# default page
	select_page(GameState.journal_page)


# ----------------------------
# SLOT SYSTEM (UNCHANGED)
# ----------------------------

func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i

		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)
		slot.mouse_entered.connect(func(): on_slot_hovered(slot))
		slot.mouse_exited.connect(func(): hide_description())

func on_slot_hovered(slot):

	if slot.isEmpty():
		return

	var item = slot.itemStackGui.inventorySlot.item

	print(item.description)

	description_box.visible = true
	description_label.text = item.description

func hide_description():

	description_box.visible = false

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
	notification_icon.visible = false
	opened.emit()
	await get_tree().process_frame
	select_page(GameState.journal_page)
	if !GameState.journal_tutorial_seen:

		GameState.journal_tutorial_seen = true

		show_journal_tutorial()

func show_journal_tutorial():

	tutorial_active = true
	tutorial_index = 0

	tutorial_panel.visible = true

	show_tutorial_line()

func show_tutorial_line():

	tutorial_label.text = tutorial_lines[tutorial_index]

func close():
	visible = false
	isOpen = false
	closed.emit()

func onSlotClicked(slot):
	var index = slot.index
	hotbar.select_slot(index)

	if slot.isEmpty():
		if !itemInHand:
			return
		insertItemInSlot(slot)
		return

	if !itemInHand:
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
	var totalAmount = slotItem.inventorySlot.amount + itemInHand.inventorySlot.amount

	if slotItem.inventorySlot.amount == maxAmount:
		swapItems(slot)
		return

	slotItem.update()
	if itemInHand:
		itemInHand.update()

func updateItemInHand():
	if !itemInHand:
		return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func _input(event):
	updateItemInHand()
	if tutorial_active:

		if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:

				tutorial_index += 1

				if tutorial_index >= tutorial_lines.size():

					end_tutorial()

				else:
					show_tutorial_line()
func end_tutorial():

	tutorial_active = false
	tutorial_panel.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("toggle_inventory"):
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


# ----------------------------
# PAGE SYSTEM
# ----------------------------
func select_page(page: String):
	GameState.journal_page = page

	inventory_page.visible = false
	settings_page.visible = false
	quest_page.visible = false
	info_page.visible = false

	match page:
		"inventory":
			inventory_page.visible = true
		"settings":
			settings_page.visible = true
		"quest":
			quest_page.visible = true
		"info":
			info_page.visible = true

	# buttons
	for b in buttons:
		reset_button(b)

	match page:
		"inventory":
			activate_button(inventory_button)
		"settings":
			activate_button(settings_button)
		"quest":
			activate_button(quest_button)
		"info":
			activate_button(info_button)

func activate_button(btn: Button):
	var base_pos = button_base_positions[btn]

	var tween = create_tween()
	tween.tween_property(btn, "position", base_pos + Vector2(0, -10), 0.1)
	tween.parallel().tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)

func reset_button(btn: Button):
	var base_pos = button_base_positions[btn]

	var tween = create_tween()
	tween.tween_property(btn, "position", base_pos, 0.1)
	tween.parallel().tween_property(btn, "scale", Vector2(1, 1), 0.1)

# ----------------------------
# BUTTON SIGNALS
# ----------------------------

func _on_inventory_button_pressed():
	select_page("inventory")

func _on_settings_button_pressed():
	select_page("settings")

func _on_quest_button_pressed():
	select_page("quest")

func _on_info_button_pressed():
	select_page("info")



func _on_map_completed():
	show_map()


func show_map():
	map_image.visible = true

func load_level(path: String):


	# close journal first
	visible = false
	isOpen = false

	# unpause game
	get_tree().paused = false


	get_tree().change_scene_to_file(path)

func _on_level_1_button_pressed() -> void:
	load_level("res://levels/truelevel_1.tscn")


func _on_level_2_button_pressed() -> void:
	load_level("res://levels/truelevel_2.tscn")

func update_journal():
	print("USB STATE:", GameState.usb_inserted)
	$NinePatchRect/inventory_page/Label2.text = str(Journal.artifacts.size())

	if GameState.usb_inserted:
		
		usb_image.visible = true
		
	else:
		usb_image.visible = false
	if GameState.robot_password_learned:
		password_image.visible = true
	else:
		password_image.visible = false


func _on_journal_button_pressed() -> void:
	if !isOpen:
		open()
	else:
		close()

	$"../JournalButton".release_focus()
	get_viewport().set_input_as_handled()
