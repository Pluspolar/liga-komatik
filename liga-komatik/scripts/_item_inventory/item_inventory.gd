extends RigidBody2D
var item_id: String

func _ready():
	add_to_group("item_inventory")
	gravity_scale = 0.15
	rotation_degrees = randi_range(-60, 60)
	
func _process(_delta: float) -> void:
	if MousePointer.hovered == self:
		var distance = global_position.distance_to(get_global_mouse_position())*1.5
		linear_velocity = (get_global_mouse_position() - global_position)*(650/(distance+100))
	if (position.y > get_viewport_rect().size.y or position.x > get_viewport_rect().size.x or position.x < 0 or position.y < -15):
		Global._drop_item(item_id)
		call_deferred("queue_free")
	
