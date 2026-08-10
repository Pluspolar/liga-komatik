extends CanvasLayer
@onready var dialog = $dialogue
const cook = preload("uid://cnqh7ocygiu32")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	dialog.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cooook_button_down() -> void:
	set_process(false)
	get_tree().change_scene_to_packed(cook)


func _on_repeat_button_down() -> void:
	pass # Replace with function body.


func _on_gossip_button_down() -> void:
	pass # Replace with function body.
