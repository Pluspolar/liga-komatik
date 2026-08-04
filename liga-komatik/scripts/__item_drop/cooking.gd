extends Node2D
@onready var slop = $Slop
@onready var spatula = $Spatula
const FOOD = preload("uid://dhnglshdg05fo")
@onready var total_nutrition : float = slop.scale.x

#var tween: Tweener

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slop.scale= Vector2(0,0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$Slop/AnimationPlayer.play("new_animation")
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var newFood : food = FOOD.instantiate()
		newFood.done.connect(bigger)
		newFood.global_position = Vector2(0,0)
		
		add_child(newFood)
		
	spatula_physics(delta)
	
func spatula_physics(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		spatula.linear_velocity = (get_global_mouse_position() - spatula.global_position)*10
		if Input.is_action_pressed("right-hand") and spatula.angular_velocity >= -6.0:
			if spatula.angular_velocity > 0: spatula.angular_velocity *= pow(0.7, delta*60)
			spatula.angular_velocity -= 16.0 * delta
		elif Input.is_action_pressed("left-hand") and spatula.angular_velocity <= 6.0:
			if spatula.angular_velocity < 0: spatula.angular_velocity *= pow(0.7, delta*60)
			spatula.angular_velocity += 16.0 * delta
	else:
		#spatula.linear_velocity *= pow(0.92, delta*60) 
		spatula.linear_velocity *= pow(0.8, delta*60)
		spatula.angular_velocity = (0-spatula.rotation_degrees)*0.05
		
	slop.rotation_degrees += 8 * delta
		
func bigger(nutri):
	var nutrition = nutri/3
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	total_nutrition += nutrition
	if total_nutrition < 0.8: #if slop.scale < Vector2(0.8,0.8):
		tween.tween_property(slop, "scale", Vector2(1,1)*total_nutrition, 1)
		#slop.scale += pow((Vector2(nutrition, nutrition) - slop.scale), 0.95)
		#slop.scale += Vector2(nutrition, nutrition)
	else: tween.tween_property(slop, "scale", Vector2(1,1)*0.8, 1)
	tween.play()
