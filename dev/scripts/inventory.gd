extends Control
class_name Inventory

var inventory_item_scene = preload("res://dev/scenes/InventoryItem.tscn")

@export var rows: int = 10
@export var cols: int = 5
@export var ai_rows: int = 3
@export var ai_cols: int = 3

@export var inventory_grid: GridContainer
@export var armor_inventory_grid: GridContainer

@export var inventory_slot_scene: PackedScene
@export var inventory_empty_slot_scene: PackedScene
var slots: Array[InventorySlot]
var armor_slots: Array[InventorySlot]

@export var tooltip: Tooltip # Must be shared among all instanesself


static var selected_item: Item = null

func _ready():
	armor_inventory_grid.columns = ai_cols
	inventory_grid.columns = cols
	for i in range(ai_rows * ai_cols):
		if i==0 or i ==2 or i==6 or i==8:
			var empty_slot = inventory_empty_slot_scene.instantiate()
			armor_slots.append(empty_slot)
			armor_inventory_grid.add_child(empty_slot)
		else:
			var slot = inventory_slot_scene.instantiate()
			armor_slots.append(slot)
			armor_inventory_grid.add_child(slot)
			slot.slot_input.connect(self._on_slot_input) # binding not necessary as
			slot.slot_hovered.connect(self._on_slot_hovered) # it does while emit() call
	for i in range(rows * cols):
		var slot = inventory_slot_scene.instantiate()
		slots.append(slot)
		inventory_grid.add_child(slot)
		slot.slot_input.connect(self._on_slot_input) # binding not necessary as
		slot.slot_hovered.connect(self._on_slot_hovered) # it does while emit() call
	tooltip.visible = false
	
	var dev_item = Item.new()
	dev_item.item_name = "Battle Axe"
	dev_item.item_icon_path =  ImageTexture.create_from_image(Image.load_from_file("res://assets/dev/sprites/axe lvl 2 tile.png"))
	dev_item.item_scene_path = "res://dev/scenes/Items/BattleAxe.tscn"
	dev_item.durability = 100.0
	dev_item.is_stackable = false
	self.add_item(dev_item, 1)
	
	var dev2_item = Item.new()
	dev2_item.item_name = "Dirt"
	dev2_item.item_icon_path =  ImageTexture.create_from_image(Image.load_from_file("res://assets/dev/sprites/dirt tile.png"))
	dev_item.item_scene_path = ""
	dev2_item.durability = 0
	dev2_item.is_stackable = true
	self.add_item(dev2_item, 30)
	
func _on_slot_input(which: InventorySlot, action: InventorySlot.InventorySlotAction):
	print(action)
	# Select/deselect items
	if not selected_item:
		# Spliting only occurs if not item selected already
		if action == InventorySlot.InventorySlotAction.SELECT:
			selected_item = which.select_item()
			if $"/root/GameConstants".weapon_names.has(selected_item.item_name) and armor_slots[3].item != null:
				selected_item.add_to_group("weapon")
				print("Equiped")
			if $"/root/GameConstants".weapon_names.has(selected_item.item_name) and armor_slots[3].item == null:
				selected_item.remove_from_group("weapon")
				print("Removed")
		elif action == InventorySlot.InventorySlotAction.SPLIT:
			selected_item = which.split_item() # Split means selecting half amount
	else:
		selected_item = which.deselect_item(selected_item)



func _on_slot_hovered(which: InventorySlot, is_hovering: bool):
	if which.item:
		tooltip.set_text(which.item.item_name)
		tooltip.visible = is_hovering
	elif which.hint_item:
		tooltip.set_text(which.hint_item.item_name)
		tooltip.visible = is_hovering
		
func _process(delta):
	tooltip.global_position = get_global_mouse_position() + Vector2.ONE * 8
	if selected_item:
		tooltip.visible = false
		selected_item.global_position = get_global_mouse_position()
func add_item(item: Item, amount: int) -> void:
	var _item: InventoryItem = inventory_item_scene.instantiate() # Duplicate
	_item.set_data(
		item.item_name, item.item_icon_path, item.item_scene_path, item.durability, item.is_stackable, amount
	)
	
	item.queue_free() # Consume the item by inventory (by the end of frame)
	
	if $"/root/GameConstants".weapon_names.has(_item.item_name) and !_item.is_stackable:
		for i in range(armor_slots.size()):
			if i == 3 and armor_slots[i].item == null:
				armor_slots[i].item = _item
				armor_slots[i].update_slot()
				_item.add_to_group("weapon")
				return
	
	if $"/root/GameConstants".armor_names.has(_item.item_name) and !_item.is_stackable:
		if _item.item_name.contains("Boots"):
			for i in range(armor_slots.size()):
				if i == 7 and armor_slots[i].item == null:
					armor_slots[i].item = _item
					armor_slots[i].update_slot()
					return
		elif _item.item_name.contains("Helmet"):
			for i in range(armor_slots.size()):
				if i == 1 and armor_slots[i].item == null:
					armor_slots[i].item = _item
					armor_slots[i].update_slot()
					return
		elif _item.item_name.contains("Armor"):
			for i in range(armor_slots.size()):
				if i == 4 and armor_slots[i].item == null:
					armor_slots[i].item = _item
					armor_slots[i].update_slot()
					return
	if item.is_stackable:
		for slot in slots:
			if slot.item and slot.item.item_name == _item.item_name: # if item and is of same type
				slot.item.amount += _item.amount
				return
	for slot in slots:
		if slot.item == null and slot.is_respecting_hint(_item):
			slot.item = _item
			slot.update_slot()
			return



# !DESTRUCTUVE (removes from inventory if retrieved)
#A function to remove item from inventory and return if it exists
func retrieve_item(_item_name: String) -> Item:
	for slot in slots:
		if slot.item and slot.item.item_name == _item_name:
			var copy_item := Item.new()
			copy_item.item_name = slot.item.item_name
			copy_item.name = copy_item.item_name
			copy_item.item_icon_path = slot.item.item_icon_path
			copy_item.is_stackable = slot.item.is_stackable
			copy_item.item_scene_path = slot.item.item_scene_path
			copy_item.durability = slot.item.durability
			
			if slot.item.amount > 1:
				slot.item.amount -= 1
			else:
				slot.remove_item()
			return copy_item
	return null



# !NON-DESTRUCTIVE (read-only function) to get all items in inventory
func all_items() -> Array[Item]:
	var items: Array[Item] = []
	for slot in slots:
		if slot.item:
			items.append(slot.item)
	return items



# ! NON-DESTRUCTUVE (read-only), returns all items of a particular type
func all(_name: String) -> Array[Item]:
	var items: Array[Item] = []
	for slot in slots:
		if slot.item and slot.item.item_name == _name:
			items.append(slot.item)
	return items



# !DESTRUCTUVE (removes all items of a particular type)
func remove_all(_name: String) -> void:
	for slot in slots:
		if slot.item and slot.item.item_name == _name:
			slot.remove_item()
			print("Removed")



# !DESTRUCTUVE (removes all items from inventory)
func clear_inventory() -> void:
	for slot in slots:
		slot.remove_item()
