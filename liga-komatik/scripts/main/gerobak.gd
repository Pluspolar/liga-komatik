extends CharacterBody2D

@onready var sprite = $sprite
var bigger_velocity : Array = ["x", 0]
var map_sprite: Sprite2D

func _process(delta: float) -> void:
	anim_check()
	
	
func anim_check():
	if abs(velocity.x) >= abs(velocity.y): bigger_velocity = ["x", velocity.x]
	else: bigger_velocity = ["y", velocity.y]
	if bigger_velocity[0] == "x":
		if velocity.x < 0:
			sprite.play("left")
		else:
			sprite.play("right")
	elif bigger_velocity[0] == "y":
		if velocity.y < 0:
			sprite.play("up")
		else:
			sprite.play("down")
