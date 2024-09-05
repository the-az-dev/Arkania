extends CharacterBody2D

const SPEED = 150.0
const accel = 5000
const friction = 600

var input = Vector2.ZERO

@export var inventory: Inventory

func _ready():
	var weapon = get_tree().get_first_node_in_group("weapon")
	var weapon_scene = ResourceLoader.load(weapon.item_scene_path).instantiate()
	get_node("Weapon").add_child(weapon_scene)

func _process(delta: float) -> void:
	var weapon = get_tree().get_first_node_in_group("weapon")
	if weapon == null:
		var chldrn = get_node("Weapon").get_children()
		for child in chldrn:
			child.free()
	else:
		var weapon_scene = ResourceLoader.load(weapon.item_scene_path).instantiate()
		if get_node("Weapon").get_child_count() == 0:
			get_node("Weapon").add_child(weapon_scene)

func get_input():
	input.x = Input.get_axis("LEFT", "RIGHT")
	input.y = Input.get_axis("UP", "DOWN")
	return input.normalized()

func _physics_process(delta: float) -> void:
	input = get_input()
	
	if Input.is_action_just_pressed("INVENTORY"):
		if $"CanvasLayer/UI/Inventory".visible == false:
			$"CanvasLayer/UI/Inventory".visible = true
		elif $"CanvasLayer/UI/Inventory".visible == true:
			$"CanvasLayer/UI/Inventory".visible = false
	
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else: 
			velocity = Vector2.ZERO
	else:
		velocity += (input * 5000 * delta)
		velocity = velocity.limit_length(SPEED)

	
	move_and_slide()
