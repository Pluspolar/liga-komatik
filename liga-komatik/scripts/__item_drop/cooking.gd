extends Node2D
@onready var slop = $Slop
const FOOD = preload("uid://dhnglshdg05fo")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slop.scale= Vector2(0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Slop/AnimationPlayer.play("new_animation")
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var newFood : food = FOOD.instantiate()
		newFood.done.connect(bigger)
		newFood.global_position = Vector2(0,0)
		
		add_child(newFood)

func bigger(nutri):
	var nutrition = nutri/3
	if slop.scale < Vector2(0.8,0.8):
		slop.scale += Vector2(nutrition, nutrition)
