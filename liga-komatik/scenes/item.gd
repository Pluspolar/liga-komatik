extends RigidBody2D
var is_mouse_entered = false
var is_dragging = false
var item_id: String

func _ready():
	gravity_scale = 0.15
	rotation_degrees = randi_range(-60, 60)
	#Global.add_item("test", 10, item_id)
	#print(Global.inventory)
	
func _process(delta: float) -> void:
	#print(distance)
	if Input.is_action_pressed("click") and ((is_mouse_entered  and !Global.is_mouse_dragging) or is_dragging):
		is_dragging = true
		Global.is_mouse_dragging = true
		var distance = position.distance_to(get_global_mouse_position())*1.5
		linear_velocity = (get_global_mouse_position() - position)*(650/(distance+100))
	elif !Input.is_action_pressed("click") and is_dragging:
		is_dragging = false
		Global.is_mouse_dragging = false
	
	if (Input.is_action_pressed("right_click") and is_mouse_entered and !Global.is_mouse_dragging) or (position.y > get_viewport_rect().size.y or position.x > get_viewport_rect().size.x or position.x < 0 or position.y < -15):
		Global.drop_item(item_id)
		call_deferred("queue_free")

func _on_mouse_entered() -> void:
	is_mouse_entered = true

func _on_mouse_exited() -> void:
	is_mouse_entered = false
