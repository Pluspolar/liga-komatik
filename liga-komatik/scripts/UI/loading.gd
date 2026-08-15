extends CanvasLayer
@onready var loading_text = $loading
@onready var background = $background
@onready var dot_loading = $dot_loading
var loading_timer : float = 0
var dot_amount : int = 0

func fade_out(tick : int) -> void:
	hide_text()
	for i in range(tick+1):
		background.material.set_shader_parameter("fade", 1.0-(float(i)/float(tick)))
		await get_tree().process_frame
	queue_free()

func _process(delta: float) -> void:
	loading_timer += delta * 10
	dot_amount = int(loading_timer) % 4 + 1
	dot_loading.text = ""
	
	for i in range(dot_amount):
		dot_loading.text += "."
	
func hide_text():
	loading_text.hide()
	dot_loading.hide()
