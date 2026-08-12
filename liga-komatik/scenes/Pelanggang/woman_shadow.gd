extends Sprite2D
signal entered
signal done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func getOut() -> void:
	position = Vector2(211.0, 102.0) 
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", Vector2(600, 102.0), 2.0)
	tween.tween_callback(emit_signal.bind("done"))
	
func getIn() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", Vector2(211.0, 102.0), 2.0)	
	tween.tween_callback(emit_signal.bind("entered"))
	
