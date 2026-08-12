extends Node2D
class_name pelanggang
@onready var sprite = $WomanShadow
@onready var des = $"1"
var first = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if first:
		sprite.getIn()
	else:
		print("work")
		sprite.getOut()
		des.done()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_woman_shadow_done() -> void:
	sprite.position = Vector2(-112.19,102.0)
	sprite.getIn()
	


func _on_woman_shadow_entered() -> void:
	des.start()
