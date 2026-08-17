extends Node2D

@onready var heart = $heart
@onready var days_left = $days_left
@onready var org_position = position
var org_modulate = Color(0,0,0,1)
var cur_modulate = Color(1,1,1,1)
var random_rad = PI
var modulate_change = Color(1,1,1,1)

func _ready() -> void:
	Global.heart = self
	_shake()

func _process(delta: float) -> void:
	var cur_days_count : float = clamp(Global.days_left, 0 ,5)
	heart.material.set_shader_parameter("player_health", cur_days_count/5)
	heart.material.set_shader_parameter("cur_modulate", cur_modulate)
	modulate_change = (org_modulate - cur_modulate) * 5 * delta
	cur_modulate += modulate_change
	
	#var plural_check : String = " [color=#ffffff]Days Left"
	#if Global.days_left <= 1: plural_check = " [color=#ffffff]Day Left"
	
	var show_days_left = float(int(Global.days_left*10))/10
	if int(show_days_left)*10 == int(Global.days_left*10): show_days_left = int(show_days_left)
	#days_left.text = "[wave amp=5][color=#ff1f00]" + str(show_days_left) + plural_check
	days_left.text = "[wave amp=5][color=#ff1f00]" + str(show_days_left) + " [color=#ffffff]Hari"
	
func _shake():
	while true:
		var modulate_change_total = abs(modulate_change.r)+abs(modulate_change.g)+abs(modulate_change.b)
		random_rad = randf_range(-PI, PI)
		position = org_position + 5 * Vector2(cos(random_rad), sin(random_rad)) * (modulate_change_total)
		if get_tree() != null: await get_tree().create_timer(0.05).timeout
	
func change_day(amount : float):
	Global.days_left += amount
	if Global.days_left < 0: Global.days_left = 0
	if amount < 0: cur_modulate = Color(-0.5,-1,-1,1)
	elif amount > 0: cur_modulate = Color(-1,0.8,-1,1)
