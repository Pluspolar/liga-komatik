extends RigidBody2D
var item_id: String

func _ready():
	if Global.cur_scene == "central_inventory": 
		add_to_group("item_central")
		gravity_scale = 0
		collision_mask = 64
		collision_layer = 64
		linear_damp = 5.0
		angular_damp = 5.0
	else: 
		add_to_group("item_inventory")
		rotation_degrees = randi_range(-60, 60)
	
func in_item_inventory():
	if MousePointer.hovered == self:
		var distance = global_position.distance_to(get_global_mouse_position())*1.5
		linear_velocity = (get_global_mouse_position() - global_position)*(650/(distance+100))
	if Global.is_exploring and (position.y > get_viewport_rect().size.y or position.x > get_viewport_rect().size.x or position.x < 0 or position.y < -15):
		Global._drop_item(item_id)
		call_deferred("queue_free")
		
func in_item_central():
	var global_mouse = get_global_mouse_position()
	global_mouse = Vector2(clamp(global_mouse.x, -75, 450), clamp(global_mouse.y, -90, 310))
	print(global_mouse)
	if MousePointer.hovered == self:
		linear_velocity = (global_mouse - global_position)*10 # 224+16, 288+16
	if (position.x < -96 or position.y < -110 or position.x > 476 or position.y > 331):
		position = Global.viewport_tree.size/2
		sleeping = true
	else: sleeping = false
	
func _process(_delta: float) -> void:
	if is_in_group("item_inventory"): in_item_inventory()
	elif is_in_group("item_central"): in_item_central()
	
