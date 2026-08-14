extends Node2D

@onready var heart = $heart

func _process(delta: float) -> void:
	heart.material.set_shader_parameter("player_health", Global.player_health/Global.player_max_health)
	
