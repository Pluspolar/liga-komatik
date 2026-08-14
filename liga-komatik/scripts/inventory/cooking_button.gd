extends Button

func _ready() -> void:
	button_down.connect(_button_down)

func _process(delta: float) -> void:
	visible = !Global.item_count_central.visible
	if !visible: return
	if is_hovered(): modulate = Color(1, 1, 0.3)
	else: modulate = Color(1, 1, 1)
	
func _button_down():
	Global.change_scene_to("customer")
