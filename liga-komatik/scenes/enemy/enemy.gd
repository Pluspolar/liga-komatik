extends CharacterBody2D
var cur_path : Array = []
var cur_path_tile : Array = []
var _cur_tile : Vector2i = Vector2(0,0)
var pathing_interval : float = 0.5
var aggro_dur : float = 0
var non_aggro_dir : float = 0
var cur_angle_to : float = 0
var enemy_name : String = "enemy_1"
var bigger_velocity : Array = ["y", 0]

@onready var sprite = $sprite
@onready var raycast_1 = $raycast_1
@onready var raycast_2 = $raycast_2
@onready var raycast_3 = $raycast_3
@onready var all_raycast = [raycast_1, raycast_2, raycast_3]

@export var speed : float = 65
@export var sight_range : float = 125
@export var follow_dur : float = 8

func go_to_path():
	#var target_pos = cur_path[-1] - global_position
	if !raycast_1.enabled: for _ray in all_raycast: _ray.enabled = true
	
	if !cur_path.is_empty(): 
		if aggro_dur > 0: cur_angle_to = global_position.angle_to_point(cur_path[-1])
		else: 
			if cur_path.size() == 1: cur_angle_to = global_position.angle_to_point(cur_path[0])
			else: cur_angle_to = global_position.angle_to_point(cur_path[1])
			non_aggro_dir = cur_angle_to
	else: 
		cur_angle_to = non_aggro_dir
		velocity = Vector2.ZERO
	
	var cur_rot_degree = rad_to_deg(cur_angle_to)-7.5
	
	#var ray_count : int = 0
	for ray_ind in range(all_raycast.size()):
		var ray_direction = deg_to_rad(cur_rot_degree+ray_ind*7.5)
		all_raycast[ray_ind].target_position = Vector2(cos(ray_direction), sin(ray_direction)) * 125
		var cur_collider = all_raycast[ray_ind].get_collider()
		if cur_collider != null:
			if cur_collider.is_in_group("player"):
				aggro_dur = follow_dur
	
	#var raycast_angles : Array = [0,0,0]
	
	if cur_path.is_empty(): 
		#for _ray in all_raycast: _ray.enabled = false
		return global_position
	velocity = global_position.direction_to(cur_path[0])*speed
	if _cur_tile == cur_path_tile[0]: 
		cur_path.remove_at(0)
		cur_path_tile.remove_at(0)
	
	move_and_slide()
	
	#for _ray in all_raycast: _ray.enabled = false
	return global_position
	
func _check_anim():
	if velocity.length() < 7.0: is_idle()
	else: is_walking()
	
func is_walking():
	if abs(velocity.x) >= abs(velocity.y): bigger_velocity = ["x", velocity.x]
	else: bigger_velocity = ["y", velocity.y]
	if bigger_velocity[0] == "x":
		sprite.play(enemy_name + "_side")
	elif bigger_velocity[0] == "y":
		if velocity.y < 0:
			sprite.play(enemy_name + "_up")
		else:
			sprite.play(enemy_name + "_down")
			
	if velocity.x > 0:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
		
	var cur_sf = sprite.sprite_frames
	cur_sf.set_animation_speed(sprite.animation, abs(velocity.length())*0.085)
	
func is_idle():
	var dir_cur_angle = Vector2(cos(cur_angle_to), sin(cur_angle_to))
	if sprite.animation == (enemy_name + "_side") or (abs(dir_cur_angle.x) >= 0.5 and abs(dir_cur_angle.y) <= 0.5):
		sprite.play(enemy_name + "_idle_side")
		if dir_cur_angle.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
	elif sprite.animation == (enemy_name + "_down") or (abs(dir_cur_angle.x) < 0.5 and dir_cur_angle.y > 0.5):
		sprite.play(enemy_name + "_idle_down")
	elif sprite.animation == (enemy_name + "_up") or (abs(dir_cur_angle.x) < 0.5 and dir_cur_angle.y < -0.5) :
		sprite.play(enemy_name + "_idle_up")
