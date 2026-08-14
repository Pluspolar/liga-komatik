extends AnimatedSprite2D
signal entered
signal done

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
	
