extends Node2D

@export var amount_layer : int = 20

@onready var crate_outline = $crate_outline 
@onready var crate_floor = $crate_floor
@onready var _scroll_offset = get_viewport_rect().size/2

var crate_layer = preload("res://scenes/inventory/crate_layer.tscn")
var obj_list : Array = []

func _ready() -> void:
	var base_modulate = 0.4
	var amount_formula = (0.0175*20/amount_layer)
	crate_floor.modulate = Color(1,1,1)*base_modulate
	crate_floor.modulate.a = 1.0
	for i in range (amount_layer):
		var new_crate_layer = crate_layer.instantiate()
		new_crate_layer.scroll_scale = i*amount_formula
		new_crate_layer.modulate = Color(1,1,1)*(i*amount_formula+base_modulate)
		new_crate_layer.modulate.a = 1.0
		crate_outline.add_child(new_crate_layer)
		obj_list.append(new_crate_layer)
		
func _process(delta: float) -> void:
	if Global.cur_scene == "central_inventory":
		var local_cam_coords = Global.cam_coords-_scroll_offset
		for obj in obj_list:
			obj.position = local_cam_coords*obj.scroll_scale+_scroll_offset
		
