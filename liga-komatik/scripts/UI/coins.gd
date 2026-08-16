extends Node2D

@onready var icon = $icon
@onready var coins_count = $coins_count

var org_modulate = Color(1,1,1,1)
var cur_modulate = Color(1,1,1,1) 
var modulate_change = Color(1,1,1,1) 
@onready var org_position = position

func _ready() -> void:
	Global.coin_icon = self
	_shake()

func _process(delta: float) -> void:
	modulate_change = (org_modulate - cur_modulate) * 10 * delta
	cur_modulate += modulate_change
	modulate = cur_modulate
	coins_count.text = str(Global.coins)

func _shake():
	while true:
		var modulate_change_total = abs(modulate_change.r)+abs(modulate_change.g)+abs(modulate_change.b)
		var random_rad = randf_range(-PI, PI)
		position = org_position + 3 * Vector2(cos(random_rad), sin(random_rad)) * (modulate_change_total)
		await get_tree().create_timer(0.05).timeout

func change_coin(amount: int):
	Global.coins += amount
	if amount < 0: cur_modulate = Color(1,0,0,1)
	elif amount > 0: 
		Global.coins_earned += amount
		cur_modulate = Color(0,1,0,1)
	
