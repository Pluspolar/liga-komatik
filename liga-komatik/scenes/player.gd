extends CharacterBody2D

func _physics_process(_delta: float) -> void:
	Global.player_pos = global_position
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and Global.cur_scene == "interior":
		Global.change_scene_to("outside", Node)
	if event.is_action_pressed("interact") and Global.cur_scene == "outside":
		var _areas = $Interaction.get_overlapping_areas()
		for _area in _areas:
			if _area.is_in_group("interior_interaction"):
				Global.change_scene_to("interior", get_to_staticbody(_area))

func get_to_staticbody(_area):
	var cur_area = _area
	while cur_area.get_class() != "StaticBody2D":
		cur_area = cur_area.get_parent()
	return cur_area
