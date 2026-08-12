extends Button

@export var id : String = ""
var main_scene = preload("res://scenes/main/exploration.tscn")

func _ready() -> void:
	button_down.connect(_button_down.bind(id))

func _process(delta: float) -> void:
	var child_text = self.get_child(0)
	if is_hovered(): 
		modulate = Color(1, 1, 0.31)
		get_parent().is_button_hovering = true
		child_text.scale += (Vector2(1.1, 1.1) - child_text.scale) * 10 * delta
	else: 
		modulate = Color(1, 1, 1)
		child_text.scale += (Vector2(1,1) - child_text.scale) * 10 * delta
		
func _button_down(cur_id):
	if cur_id == "start":
		get_tree().change_scene_to_packed(main_scene)
	elif cur_id == "quit":
		get_tree().quit()
	
	
