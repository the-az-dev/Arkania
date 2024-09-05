extends Control
class_name InventorySlot

# So its copy can be instanced while splitting
@export var inventory_item_scene: PackedScene = preload("res://dev/scenes/InventoryItem.tscn")

@export var item: InventoryItem
@export var hint_item: InventoryItem = null

# hint_item SERVE TO RESTRICT A SLOT TO ONLY
# ACCEPT THE TYPE OF ITEM REPRESENTED BY THE hint_item


enum InventorySlotAction {
	SELECT, SPLIT, # FOR ITEM SELECTION
}


signal slot_input(which: InventorySlot, action: InventorySlotAction)
signal slot_hovered(which: InventorySlot, is_hovering: bool)



func _ready():
	add_to_group("inventory_slots")


# When slot is pressed
func _on_texture_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_input.emit(
				self, InventorySlotAction.SELECT
			)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slot_input.emit(
				self, InventorySlotAction.SPLIT
			)



func _on_texture_button_mouse_entered():
	slot_hovered.emit(self, true)



func _on_texture_button_mouse_exited():
	slot_hovered.emit(self, false)




# Is it having same type and amount as indicated by the hint_item
func is_respecting_hint(new_item: InventoryItem, in_amount_as_well: bool = true) -> bool:
	if not hint_item:
		return true
	if in_amount_as_well:
		return (
			new_item.item_name == self.hint_item.item_name
			and new_item.amount >= self.hint_item.amount
		)
	else:
		return new_item.item_name == self.hint_item.item_name



# Sets hint item
func set_item_hint(new_item_hint: InventoryItem):
	if self.hint_item:
		self.hint_item.free()
	self.hint_item = new_item_hint
	self.add_child(new_item_hint)
	update_slot()


# Deletes hint item
func clear_item_hint():
	if self.hint_item:
		self.hint_item.free()
	self.hint_item = null
	update_slot()



# Removes item from slot
func remove_item():
	self.remove_child(item)
	if $"/root/GameConstants".weapon_names.has(item.item_name):
		item.remove_from_group("weapon")
		print("Removed")
		pass
	item.free()
	item = null
	update_slot()
	print("Removed from slot")




# Removes item from slot and returns it.
func select_item() -> InventoryItem:
	var inventory = self.get_parent().get_parent() # Inventory
	var tmp_item := self.item
	if tmp_item:
		tmp_item.reparent(inventory)
		self.item = null
		tmp_item.z_index = 128
	# Show it above other items
	return tmp_item





# If swap, then returb swapped item, else return null and add new item
func deselect_item(new_item: InventoryItem) -> InventoryItem:
	if not is_respecting_hint(new_item):
		return new_item # Do nothing
	var inventory = self.get_parent().get_parent() # Inventory
	if self.is_empty():
		new_item.reparent(self)
		self.item = new_item
		self.item.z_index = 64
		return null
	else:
		if self.has_same_item(new_item): # if both items are same
			print("Has same item")
			self.item.amount += new_item.amount
			new_item.free()
			return null
		else: # if different type, swap
			new_item.reparent(self) # Make new thing our child
			self.item.reparent(inventory) # make old thing inventory child
			var tmp_item = self.item
			self.item = new_item
			new_item.z_index = 64 # Reset its z index
			tmp_item.z_index = 128 # Update swapped item's z index
			return tmp_item



# Split means selecting half amount
func split_item() -> InventoryItem:
	if self.is_empty():
		return null
	var inventory = self.get_parent().get_parent() # Inventory
	if self.item.amount > 1:
		var new_item: InventoryItem = inventory_item_scene.instantiate()
		new_item.set_data(
			self.item.item_name, self.item.item_icon_path, self.item.item_scene_path, self.item.durability,
			self.item.is_stackable, self.item.amount
		) # Because .duplicate() is buggy (doesnt make it unique0 thats why duplicating via this way
		new_item.amount = self.item.amount / 2
		self.item.amount -= new_item.amount
		inventory.add_child(new_item)
		new_item.z_index = 128
		return new_item
	elif self.item.amount == 1:
		return self.select_item()
	else:
		return null



# Is slot empty (has no item)
func is_empty():
	return self.item == null
	print("Done")




# Has same kind of item? (same name)
func has_same_item(_item: InventoryItem):
	return _item.item_name == self.item.item_name





func update_slot():
	if item:
		if not self.get_children().has(item):
			add_child(item)
		#item.sprite.texture = item.icon
		#item.label.text = str(item.amount) + " - " + str(item.name)
		# If amount ios 0, make iot semi-transparent
		if item.amount < 1:
			item.fade()
	if hint_item:
		if not self.get_children().has(hint_item):
			add_child(hint_item)
		hint_item.fade() # Visually look faded
