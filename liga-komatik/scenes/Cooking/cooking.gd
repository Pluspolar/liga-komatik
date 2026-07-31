extends Node2D

const FOOD = preload("uid://dhnglshdg05fo")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var newFood : food = FOOD.instantiate()
		newFood.global_position = Vector2(0,0)
		add_child(newFood)
