extends Area2D

var item_name : String
var item_id : String
var item_weight: float
var chunk_pos : Vector2i
var item_dur : float = 2
var _area_entered : bool = false

func _process(delta: float) -> void:
	item_dur -= 1 * delta
	if item_dur <= 0 and _area_entered:
		Global.add_item(self, chunk_pos, item_id, item_name, item_weight)
		call_deferred("queue_free")

func _on_area_entered(_area: Area2D) -> void:
	_area_entered = true

func _on_area_exited(_area: Area2D) -> void:
	_area_entered = false
