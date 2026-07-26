extends RigidBody2D
var is_mouse_entered = false
var is_dragging = false
var item_id: String
#var old_vel 
#var change_tick : float

func _ready():
	add_to_group("item_inventory")
	#collision_layer = 4
	#collision_mask = 20
	gravity_scale = 0.15
	#print(collision_mask)
	#rotation_degrees = randi_range(-60, 60)
	#get_parent().global_position
	#Global.add_item("test", 10, item_id)
	#print(Global.inventory)
	
func _process(delta: float) -> void:
	#print(distance)
	#if Input.is_action_pressed("click") and ((is_mouse_entered  and !Global.is_mouse_dragging) or is_dragging):
	#	is_dragging = true
	#	Global.is_mouse_dragging = true
	#	var distance = position.distance_to(get_global_mouse_position())*1.5
	#	linear_velocity = (get_global_mouse_position() - position)*(650/(distance+100))
	#elif !Input.is_action_pressed("click") and is_dragging:
	#	is_dragging = false
	#	Global.is_mouse_dragging = false
	#old_vel = linear_velocity
	#change_tick += 1
	
	#print(old_vel)
	#old_vel = linear_velocity
	if MousePointer.hovered == self:
		var distance = global_position.distance_to(get_global_mouse_position())*1.5
		linear_velocity = (get_global_mouse_position() - global_position)*(650/(distance+100))
	#reset_physics_interpolation()
	#elif change_tick > 1:
	#	change_tick = 0
	#	linear_velocity = old_vel + Global.cam_velocity * delta * 250
	#else: 
	#	old_vel = linear_velocity
	#	#print(linear_velocity)
		
	#if (Input.is_action_pressed("right_click") and is_mouse_entered and !Global.is_mouse_dragging) or (position.y > get_viewport_rect().size.y or position.x > get_viewport_rect().size.x or position.x < 0 or position.y < -15):
	#if (Input.is_action_pressed("right_click") and MousePointer.hovered == self) or (position.y > get_viewport_rect().size.y or position.x > get_viewport_rect().size.x or position.x < 0 or position.y < -15):
	if (position.y > get_viewport_rect().size.y or position.x > get_viewport_rect().size.x or position.x < 0 or position.y < -15):
		Global.drop_item(item_id)
		call_deferred("queue_free")
	
