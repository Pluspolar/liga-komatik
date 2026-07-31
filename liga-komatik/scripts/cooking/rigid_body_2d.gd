extends RigidBody2D
class_name food

@export var gravity_strength: float = 800.0

func _ready() -> void:
	# Disable the default global Y-down gravity on this body
	gravity_scale = 0.0
	var wajan = $"../wajan"
	wajan.body_exited.connect(dirty)
func dirty(junk)-> void:
	if junk == self:
		queue_free()

func _physics_process(delta: float) -> void:
	# Calculate the center point of the current viewport
	var center_of_screen: Vector2 = get_viewport_rect().size / 2.0
	
	
	var direction_to_center: Vector2 = global_position.direction_to(center_of_screen)
	

	apply_central_force(direction_to_center * gravity_strength)


func _on_wajan_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
