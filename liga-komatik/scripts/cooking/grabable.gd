extends AnimatedSprite2D
class_name  grabable
signal done(sprite)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position= get_global_mouse_position() # Replace with function body.
	done.emit(animation)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	global_position= get_global_mouse_position()
	#if Input.is_action_just_pressed("left_click"):
#	done.emit(animation)
#	queue_free()
	
#func _unhandled_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released() :
#		done.emit(animation)
#		queue_free()
		
