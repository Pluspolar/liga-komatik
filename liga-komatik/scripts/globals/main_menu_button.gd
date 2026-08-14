extends Button


var main_scene = preload("res://scenes/main/exploration.tscn")
@export var id : String = ""
@onready var cur_text = self.get_child(0)

func _ready() -> void:
	button_down.connect(_button_down)#.bind(id))
	if id == "screen_mode":
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			cur_text.text = "[tornado radius=0.8 freq=4.0]MODE:\nWINDOWED"
		else: cur_text.text = "[tornado radius=0.8 freq=4.0]MODE:\nFULLSCREEN"

func _process(delta: float) -> void:
	var child_text = self.get_child(0)
	if is_hovered(): 
		modulate = Color(1, 1, 0.31)
		if id != "screen_mode": get_parent().is_button_hovering = true
		child_text.scale += (Vector2(1.1, 1.1) - child_text.scale) * 10 * delta
	else: 
		modulate = Color(1, 1, 1)
		child_text.scale += (Vector2(1,1) - child_text.scale) * 10 * delta
		
func _button_down():
	if id == "start":
		get_tree().change_scene_to_packed(main_scene)
	elif id == "quit":
		get_tree().quit()
	elif id == "screen_mode":
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			cur_text.text = "[tornado radius=0.8 freq=4.0]MODE:\nFULLSCREEN"
		else: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			cur_text.text = "[tornado radius=0.8 freq=4.0]MODE:\nWINDOWED"
	
