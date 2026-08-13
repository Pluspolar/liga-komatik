extends Node2D
class_name pelanggang
@onready var sprite = $shadow
@onready var des = $"1"
var first = true
var entered = false
var pelanggan_list = ["woman_1", "woman_2", "man_1", "man_2", "man_3"]
var cur_pelanggan = "woman_1"

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
		
func _on_shadow_done() -> void:
	sprite.getIn()
	Global.cooking_scene.done.disabled = false
	Global.cooking_scene.done.visible = true

func _on_shadow_entered() -> void:
	des._start()
