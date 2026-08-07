extends Area2D

var item_name : String
var item_id : String
var item_nutrition: float
var item_star: int
var col_shape_enabled : bool = false
var chunk_pos : Vector2i
var interior = null
var item_dur : float = 0
@onready var col_shape = $col_shape
@onready var costume_sprite = $costume_sprite

func _ready():
	costume_sprite.play(item_name)
	if col_shape_enabled: col_shape.disabled = false
	if item_dur != 0: 
		await get_tree().create_timer(item_dur).timeout
		item_dur = 0
		
