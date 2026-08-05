extends CharacterBody2D
var _areas
var area_interact
var map_sprite: Sprite2D

func _physics_process(_delta: float) -> void:
	Global.player_pos = global_position
	_areas = $Interaction.get_overlapping_areas()
	Global.is_interacting = false
	area_interact = null
	for _area in _areas:
		if _area.is_in_group("item_drop") and _area.item_dur == 0:
			Global.add_item(_area, _area.chunk_pos, _area.item_id, _area.item_name, _area.item_star, _area.item_nutrition)
			_area.call_deferred("queue_free")
		elif _area.is_in_group("interior_interaction") and area_interact == null:
			area_interact = get_to_staticbody(_area)
			Global.is_interacting = true
	if Global.cur_scene == "interior" and global_position.distance_to(Global.player_interior_out) <= 23:
		Global.is_interacting = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and Global.cur_scene == "interior" and global_position.distance_to(Global.player_interior_out) <= 23:
		Global.change_scene_to("outside")
	elif event.is_action_pressed("interact") and Global.cur_scene == "outside" and Global.is_interacting:
		Global.change_scene_to("interior", area_interact)

func get_to_staticbody(_area):
	var cur_area = _area
	while cur_area.get_class() != "StaticBody2D":
		cur_area = cur_area.get_parent()
	return cur_area
