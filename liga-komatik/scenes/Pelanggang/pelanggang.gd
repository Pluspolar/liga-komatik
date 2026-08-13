extends Node2D
class_name pelanggang
@onready var sprite = $WomanShadow
@onready var des = $"1"
var first = true
var entered = false

func _ready() -> void:
	Global.pelanggan_scene = self

# Called when the node enters the scene tree for the first time.
func _start() -> void:
	if first:
		sprite.getIn()
	else:
		print("work")
		entered = false
		first = true
		sprite.getOut()
		des.done()
		
func _on_woman_shadow_done() -> void:
	#sprite.position = Vector2(-112.19,102.0)
	sprite.getIn()
	Global.cooking_scene.done.disabled = false
	Global.cooking_scene.done.visible = true
	
func _on_woman_shadow_entered() -> void:
	des._start()
