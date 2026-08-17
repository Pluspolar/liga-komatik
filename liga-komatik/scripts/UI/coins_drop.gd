extends Node2D

var target_pos : Vector2 = Vector2(0, 0)
var coin_amount : int = 0
var should_add : bool = false

func _ready() -> void:
	$coins_count.text = str(coin_amount)

func _process(delta: float) -> void:
	global_position += (target_pos - global_position) * 3 * delta
	
	if global_position.distance_to(target_pos) < 7:
		if should_add: Global.coin_icon.change_coin(coin_amount)
		queue_free()
		
