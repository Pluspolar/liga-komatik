extends Node2D
class_name cooks


@onready var slop = $Slop
@onready var spatula = $Spatula
const FOOD = preload("uid://dhnglshdg05fo")
@onready var total_nutrition : float = 0
@onready var cooking = true
@onready var holding = false
#@onready var Cam = $Camera2D
@onready var cook = $Marker2D
@onready var ingre = $Marker2D2
@onready var nutri_level = $nutriLevel
@onready var done = $Button
@onready var switch_shape = $Swicth/CollisionShape2D
var lvl0 = "Tidak ada"
var lvl1 = "Sedikit"
var lvl2 = "Medium"
var lvl3 = "Jumbo"
var target = 0.7
var total_nutrition : float = 0
var cooking = true
var holding = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.cooking_scene = self
	slop.scale= Vector2(0,0)
	nutri_level.text = lvl0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$Slop/AnimationPlayer.play("new_animation")
	if Global.cur_scene == "cooking": 
		spatula_physics(delta)
		if switch_shape.disabled:
			switch_shape.disabled = false
	
	#print(Global.cur_scene == "cooking")
	
func spatula_physics(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cooking and !holding:
		spatula.linear_velocity = (get_global_mouse_position() - spatula.global_position)*10
		if Input.is_action_pressed("right-hand") and spatula.angular_velocity >= -6.0:
			if spatula.angular_velocity > 0: spatula.angular_velocity *= pow(0.7, delta*60)
			spatula.angular_velocity -= 16.0 * delta
		elif Input.is_action_pressed("left-hand") and spatula.angular_velocity <= 6.0:
			if spatula.angular_velocity < 0: spatula.angular_velocity *= pow(0.7, delta*60)
			spatula.angular_velocity += 16.0 * delta
	else:
		spatula.linear_velocity *= pow(0.8, delta*60)
		spatula.angular_velocity = (0-spatula.rotation_degrees)*0.05
		
	slop.rotation_degrees += 8 * delta
		
func bigger(nutri):
	print(nutri)
	var nutrition : float = nutri/300
	print(nutrition)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	total_nutrition += nutrition
	
	#nutrition sizes indicator
	
	
	var target_nutrition : float = total_nutrition
	if target_nutrition > target : 
		done.disabled = false
		done. visible = true
	if target_nutrition > 0.05 and target_nutrition < 0.6:
		nutri_level.text = lvl1
	elif target_nutrition > 0.3 and target_nutrition < 0.7:
		nutri_level.text = lvl2
	elif target_nutrition > 0.7:
		nutri_level.text = lvl3
	elif target_nutrition == 0.0:
		nutri_level.text = lvl0	
	if target_nutrition > 0.863: target_nutrition = 0.8
	#if slop.scale.x < total_nutrition: #if slop.scale < Vector2(0.8,0.8):
	tween.tween_property(slop, "scale", target_nutrition*Vector2(1,1), 1)
		#slop.scale += pow((Vector2(nutrition, nutrition) - slop.scale), 0.95)
		#slop.scale += Vector2(nutrition, nutrition)
	#else: tween.tween_property(slop, "scale", Vector2(1, 1)*0.8, 1)
	tween.play()

func _on_swicth_mouse_entered() -> void:
	if cooking == true:
		Global.cur_cam_cooking = Vector2(-195.485, 108.0)
		#Cam.position = Vector2(-195.485, 108.0)
		cooking = false
	else : 
		Global.cur_cam_cooking = Vector2(196.0, 108.0)
		#Cam.position = Vector2(196.0, 108.0)
		cooking = true

func newIngre(play) -> void :
		holding = false
		var newFood : foods = FOOD.instantiate()
		newFood.done.connect(bigger)
		
		add_child(newFood)
		newFood.activate(play)
		newFood.sprite.play(play)
		
		newFood.global_position = get_global_mouse_position()
		
		


func _on_button_button_down() -> void:
	var change = PELANGGANG.instantiate()
	

	change.first = false
	
	# Add new scene to root and remove current scene safely
	get_tree().root.add_child(change)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = change
