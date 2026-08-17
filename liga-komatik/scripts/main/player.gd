extends CharacterBody2D
var _areas
var area_interact
var map_sprite: Sprite2D
@onready var player_sprite = $sprite
var player_sf
var bigger_velocity : Array = ["x", 0]
var can_cook : bool = false

var respite = preload("res://scenes/UI/respite.tscn")

func _ready() -> void:
	player_sf = player_sprite.sprite_frames

func _physics_process(delta: float) -> void:
	Global.player_pos = global_position
	_areas = $Interaction.get_overlapping_areas()
	Global.is_interacting = false
	area_interact = null
	can_cook = false
	for _area in _areas:
		if _area.is_in_group("gerobak"):
			_area.get_parent().velocity = velocity
			_area.get_parent().velocity += velocity*20*delta
		elif _area.is_in_group("gerobak_interact"):
			Global.is_interacting = true
			can_cook = true
		elif _area.is_in_group("item_drop") and _area.item_dur == 0:
			Global.add_item(_area, _area.chunk_pos, _area.item_id, _area.item_name, _area.item_star, _area.item_nutrition)
			_area.call_deferred("queue_free")
		elif _area.is_in_group("interior_interaction") and area_interact == null:
			area_interact = get_to_staticbody(_area)
			Global.is_interacting = true
	if Global.cur_scene == "interior" and global_position.distance_to(Global.player_interior_out) <= 23:
		Global.is_interacting = true

	if velocity.length() < 4.0: is_idle()
	else: is_walking()

func is_idle():
	if player_sprite.animation == "walk_side":
		player_sprite.play("idle side")
	elif player_sprite.animation == "walk_down":
		player_sprite.play("idle down")
	elif player_sprite.animation == "walk_up":
		player_sprite.play("idle up")
	
func is_walking():
	if abs(velocity.x) > abs(velocity.y): bigger_velocity = ["x", velocity.x]
	else: bigger_velocity = ["y", velocity.y]
	if bigger_velocity[0] == "x":
		player_sprite.play("walk_side")
		
	elif bigger_velocity[0] == "y":
		if bigger_velocity[1] > 0:
			player_sprite.play("walk_down")
		else:
			player_sprite.play("walk_up")
	
	if velocity.x > 0:
		player_sprite.scale.x = 1
	else:
		player_sprite.scale.x = -1
			
	player_sf.set_animation_speed(player_sprite.animation, abs(velocity.length())*0.085)
	
func _input(event: InputEvent) -> void:
	if Global.is_on_ui: return
	
	if event.is_action_pressed("interact") and Global.cur_scene == "interior" and global_position.distance_to(Global.player_interior_out) <= 23:
		Global.change_scene_to("outside")
	elif event.is_action_pressed("interact") and area_interact != null and Global.cur_scene == "outside" and Global.is_interacting:
		Global.change_scene_to("interior", area_interact)
	elif event.is_action_pressed("interact") and can_cook and Global.cur_scene == "outside":
		Global.player_last_loc = global_position
		get_tree().current_scene.get_node("UI").add_child(respite.instantiate())

func get_to_staticbody(_area):
	var cur_area = _area
	while cur_area.get_class() != "StaticBody2D":
		cur_area = cur_area.get_parent()
	return cur_area
