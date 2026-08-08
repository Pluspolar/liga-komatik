extends Area2D

var item_count : int = 0
var item_star : int = 0
var list_id : int = 0
var item_name : String

var half_viewport : Vector2 = Global.viewport_tree.size/2
var total_item_pos : float
var pos_x : float
var final_pos : Vector2
var final_pos_speed : Vector2 = Vector2.ZERO
var timer_rand = randf_range(-1000, 1000)*randf_range(1.5, 10.5)
var speed_rand = randf_range(3, 5)*1.5

var _prefix : String = "[wave amp=8.0 freq=3.0]"
var star_text : String = "★"
@export var separation : float = 64
@onready var costume_sprite = $costume_sprite
@onready var _star = $star
@onready var _count = $count

func _ready() -> void:	
	item_star = list_id
	if Global.central_inventory.has(item_name):
		item_count = Global.central_inventory[item_name][item_star][0]
	
	var repeat_star : String = ""
	
	for i in range(item_star): repeat_star += star_text
	_star.text = _prefix + repeat_star
	_count.text = _prefix + str(item_count)
	
	position = half_viewport + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	costume_sprite.play(item_name)

func _process(delta: float) -> void:
	var cur_timer = (Global._timer+timer_rand)*speed_rand
	var rand_pos = Vector2(sin(cur_timer/3.14), cos(cur_timer/1.5))*1.5
	total_item_pos = (Global.item_list_amount-1)*separation
	pos_x = list_id*separation-total_item_pos/2
	final_pos = Vector2(pos_x, 0) + half_viewport
	final_pos_speed = (final_pos - position+rand_pos)*0.4 + final_pos_speed*0.8
	position += final_pos_speed * 5 * delta
	
	
