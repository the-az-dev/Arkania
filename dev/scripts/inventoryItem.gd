extends Item
class_name InventoryItem

# NOTE: IT IS not SLOT AMOUNT, but currently carried amount
@export var sprite: Sprite2D
@export var amountLabel: Label
@export var durabilityProgress: ProgressBar

func set_data(_name: String, _icon: Texture2D, _scene: String, _durability: float, _is_stackable: bool, _amount: int):
	self.item_name = _name
	self.name = _name
	self.item_icon_path = _icon
	self.item_scene_path = _scene
	self.durability = _durability
	self.is_stackable = _is_stackable
	self.amount = _amount

func _ready() -> void:
	if !self.is_stackable:
		sprite.rotate(45.0)

func _process(delta):
	self.sprite.texture = self.item_icon_path
	self.set_sprite_size_to(sprite, Vector2(42, 42))
	if is_stackable:
		self.amountLabel.text = str(self.amount)
		self.durabilityProgress.visible = false
	else:
		amountLabel.visible = false
		self.durabilityProgress.value = self.durability



func set_sprite_size_to(sprite: Sprite2D, size: Vector2):
	var texture_size = sprite.texture.get_size()
	var scale_factor = Vector2(size.x / texture_size.x, size.y / texture_size.y)
	sprite.scale = scale_factor



func fade():
	self.sprite.modulate = Color(1, 1, 1, 0.4)
	self.label.modulate = Color(1, 1, 1, 0.4)
