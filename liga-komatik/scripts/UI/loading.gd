extends CanvasLayer
@onready var loading_text = $loading
@onready var dot_loading = $dot_loading
var loading_timer : float = 0
var dot_amount : int = 0

func _process(delta: float) -> void:
	loading_timer += delta * 3
	dot_amount = int(loading_timer) % 4 + 1
	dot_loading.text = ""
	
	for i in range(dot_amount):
		dot_loading.text += "."
	
