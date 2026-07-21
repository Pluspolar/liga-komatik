extends Node2D

var is_dragging : bool = false
var hovered
var mouse_area: Area2D

func _ready():
	mouse_area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 1
	shape.shape = circle
	mouse_area.add_child(shape)
	
	mouse_area.collision_layer = 0
	mouse_area.collision_mask = 4
	get_tree().current_scene.add_child(mouse_area)
	
func _process(delta: float) -> void:
	
	mouse_area.position = get_viewport().get_mouse_position() #get_global_mouse_position() - Global.cam_coords + Global.viewport_tree.size/2
	#print(mouse_area.global_position)
	var bodies = mouse_area.get_overlapping_bodies()
	var new_hovered
	
	#print(bodies)
	for _body in bodies:
		if _body.is_in_group("item_inventory"):
			if Input.is_action_pressed("right_click") and not is_dragging:
				Global.drop_item(_body.item_id)
				_body.call_deferred("queue_free")
				new_hovered = null
				hovered = null
			else:
				new_hovered = _body
				break
		
	#if !new_hovered: new_hovered = hovered
			
	if new_hovered != null and (not is_dragging) and Input.is_action_pressed("click"):
		is_dragging = true
		hovered = new_hovered
	elif !Input.is_action_pressed("click") and is_dragging:
		is_dragging = false
		hovered = null
		
	#print(is_dragging)
