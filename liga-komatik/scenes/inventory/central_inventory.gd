extends Node2D

@onready var crate_outline = $crate_outline 
@onready var crate_floor = $crate_floor
var crate_layer = preload("res://scenes/inventory/crate_layer.tscn")
@export var amount_layer : int = 20

func _ready() -> void:
	var base_modulate = 0.4
	var _scroll_offset = get_viewport_rect().size/2
	var amount_formula = (0.0175*20/amount_layer)
	crate_floor.modulate = Color(1,1,1)*base_modulate
	crate_floor.modulate.a = 1.0
	for i in range (amount_layer):
		var new_crate_layer = crate_layer.instantiate()
		new_crate_layer.scroll_scale = Vector2(1,1)*(1-(i*amount_formula))
		new_crate_layer.scroll_offset = _scroll_offset
		new_crate_layer.modulate = Color(1,1,1)*(i*amount_formula+base_modulate)
		new_crate_layer.modulate.a = 1.0
		crate_outline.add_child(new_crate_layer)
