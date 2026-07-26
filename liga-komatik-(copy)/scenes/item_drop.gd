extends Area2D

var item_name : String
var item_id : String
var item_weight: float
var item_dur : float = 2
var _body_entered : bool = false

func _process(delta: float) -> void:
	item_dur -= 1 * delta
	if item_dur <= 0 and _body_entered:
		Global.add_item(item_id, item_name, item_weight)
		call_deferred("queue_free")
	
func _on_body_entered(body: Node2D) -> void:
	_body_entered = true

func _on_body_exited(body: Node2D) -> void:
	_body_entered = false
