extends AnimatedSprite2D
class_name  grabable
signal done(sprite)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position= get_global_mouse_position() # Replace with function body.
	done.emit(animation)
	queue_free()
