extends Node
class_name Item
# 1) ID TILE
# 2) Name item
# 3) Amount (<= 20)

@export var item_name: String
@export var item_icon_path: Texture2D
@export var item_scene_path: String
@export var is_stackable: bool = false
@export var durability: float = -1.0
@export var amount: int = 0


func _ready():
	add_to_group("items")
