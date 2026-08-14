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
	mouse_area.collision_mask = 452 #4+64+128+256
	add_child(mouse_area)
	
func _process(_delta: float) -> void:
	
	if (Global.cur_scene == "central_inventory" and !Global.item_count_central.visible) or Global.cur_scene == "cooking" : mouse_area.position = get_global_mouse_position()
	else: mouse_area.position = get_viewport().get_mouse_position()
	var bodies = mouse_area.get_overlapping_bodies()
	var areas = mouse_area.get_overlapping_areas()
	var new_hovered
	
	for _body in bodies:
		if !_body.visible: continue
		
		if _body.is_in_group("item_inventory") and Global.is_opening_inventory:
			new_hovered = _body
			if Input.is_action_pressed("right_click") and not is_dragging:
				Global._drop_item(_body.item_id)
				_body.call_deferred("queue_free")
				new_hovered = null
				hovered = null
			break

		elif _body.is_in_group("item_central") and !Global.item_count_central.visible and Global.cur_scene == "central_inventory":
			new_hovered = _body
			break
		
	for _area in areas:
		if !_area.visible: continue
		
		if _area.is_in_group("item_central_interact") and Global.item_count_central.visible and Global.cur_scene == "central_inventory":
			new_hovered = _area
			if Input.is_action_just_pressed("left_click"):
				_area._mouse_pressed = "left"
				new_hovered = null
				hovered = null
			elif Input.is_action_just_pressed("right_click"):
				_area._mouse_pressed = "right"
				new_hovered = null
				hovered = null
			break
		
		if Global.cur_scene == "cooking":
			if _area.is_in_group("cooking_interact"):
				_area.get_parent()._on_swicth_mouse_entered()
				var cur_cooking = _area.get_parent().cooking
				var cur_shape = _area.get_child(0)
				cur_shape.call_deferred("set_disabled", true)
				break
			
			elif _area.is_in_group("cooking_item_list"):
				if Input.is_action_just_pressed("left_click"):
					_area.create_sprite()
				break
			
	if not Global.is_opening_inventory and Global.cur_scene != "central_inventory":
		new_hovered = null
		hovered = null
		is_dragging = false
	elif new_hovered != null and (not is_dragging) and Input.is_action_pressed("left_click"):
		is_dragging = true
		hovered = new_hovered
	elif !Input.is_action_pressed("left_click") and is_dragging:
		is_dragging = false
		hovered = null
		
	
 
