extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: pass
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	#	global_position = get_global_mouse_position()
