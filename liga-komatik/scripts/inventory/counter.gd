extends RichTextLabel

var target_obj : Object = null
var prefix : String = "[wave amp=10.0 freq=5.0]"

func _process(delta: float) -> void:
	if target_obj != null: 
		global_position = target_obj.global_position + Vector2(-size.x/2, 24)*scale.x
		text = prefix + str(target_obj.item_count)
		visible = target_obj.visible
