extends Area2D

var item_name : String
var item_id : String
var item_nutrition: float
var col_shape_enabled : bool = false
var chunk_pos : Vector2i
var interior = null
var item_dur : float = 0
@onready var col_shape = $col_shape

func _ready():
	if col_shape_enabled: col_shape.disabled = false
	if item_dur != 0: 
		await get_tree().create_timer(item_dur).timeout
		item_dur = 0
		
