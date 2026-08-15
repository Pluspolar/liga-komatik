extends Node2D

@onready var heart = $heart
@onready var health_count = $health_count
@onready var org_position = position
var org_modulate = Color(0,0,0,1)
var cur_modulate = Color(1,1,1,1)
var random_rad = PI
var modulate_change = Color(1,1,1,1)

func _ready() -> void:
	Global.heart = self
	_shake()

func _process(delta: float) -> void:
	heart.material.set_shader_parameter("player_health", Global.player_health/Global.player_max_health)
	heart.material.set_shader_parameter("cur_modulate", cur_modulate)
	modulate_change = (org_modulate - cur_modulate) * 5 * delta
	cur_modulate += modulate_change
	health_count.text = "[wave amp=5][color=#ff1f00]" + str(float(int(Global.player_health/Global.player_max_health*1000))/10) + "[color=#ffaaaa]%"
	
func _shake():
	while true:
		var modulate_change_total = abs(modulate_change.r)+abs(modulate_change.g)+abs(modulate_change.b)
		random_rad = randf_range(-PI, PI)
		position = org_position + 7 * Vector2(cos(random_rad), sin(random_rad)) * (modulate_change_total)
		await get_tree().create_timer(0.05).timeout
	
func change_hp(amount : float):
	Global.player_health += amount
	Global.player_health = clamp(Global.player_health, 0, Global.player_max_health)
	if amount < 0: cur_modulate = Color(-0.5,-1,-1,1)
	elif amount > 0: cur_modulate = Color(-1,0.8,-1,1)
