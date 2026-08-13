extends AnimatedSprite2D
signal entered
signal done

#var pelanggan_list = [ ]#Global.pelanggan_scene.pelanggan_list
#var cur_pelanggan = "" #Global.pelanggan_scene.cur_pelanggan

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	await get_tree().process_frame
#	pelanggan_list = Global.pelanggan_scene.pelanggan_list
#	cur_pelanggan = Global.pelanggan_scene.cur_pelanggan
	#pass # Replace with function body.

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
	Global.pelanggan_scene.cur_pelanggan = Global.pelanggan_scene.pelanggan_list[randi_range(0, Global.pelanggan_scene.pelanggan_list.size()-1)]
	play(Global.pelanggan_scene.cur_pelanggan)
	position = Vector2(-112.0, 102.0) 
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", Vector2(211.0, 102.0), 2.0)	
	tween.tween_callback(emit_signal.bind("entered"))
	
