extends Area2D

var item_name : String
var item_id : String
var item_weight: float
var chunk_pos : Vector2i
var interior = null
var item_dur : float = 0
@onready var col_sprite = $col_sprite

func _ready():
	if item_dur != 0: 
		await get_tree().create_timer(item_dur).timeout
		item_dur = 0

#func _process(_delta: float) -> void:
	'''if interior != null:
		
		if Global.cur_scene == "interior" and Global.cur_interior == interior:
			col_sprite.disabled = false
			show()
		else: 
			col_sprite.disabled = true
			hide()'''
		
