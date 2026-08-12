extends CharacterBody2D
var cur_path : Array = []
var cur_path_tile : Array = []
var _cur_tile : Vector2i = Vector2(0,0)
var pathing_interval : float = 0.5
@export var speed = 1000

func go_to_path():
	if cur_path.is_empty(): return global_position
	
	velocity = global_position.direction_to(cur_path[0])*50
	if _cur_tile == cur_path_tile[0]: 
		cur_path.remove_at(0)
		cur_path_tile.remove_at(0)
	
	move_and_slide()
	
	return global_position
	
