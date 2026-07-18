extends CharacterBody2D

func _physics_process(delta: float) -> void:
	Global.player_pos = global_position
	move_and_slide()
