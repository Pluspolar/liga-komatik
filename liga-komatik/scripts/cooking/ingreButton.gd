extends Area2D
const GRABABLE = preload("uid://0q5f1qfe1crj")

var cur_key = null
var cur_sprite : Object
var total_count : int = 1
var label_text : Object
var target_scale := Vector2(1.5, 1.5)

@onready var root = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_text = self.get_child(2)
	collision_layer = 256
	add_to_group("cooking_item_list")
	
	cur_sprite = self.get_child(0)
	var _sprite_frames = cur_sprite.sprite_frames
	var cur_sprite_texture = _sprite_frames.get_frame_texture(cur_sprite.animation, 0).get_size()
	cur_sprite.position.y -= cur_sprite_texture.y/4
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cooking_inv_length : int = Global.cooking_inventory.size()-1
	var cur_index = int(self.name)
	var cur_sprite_child = self.get_child(0)
	cur_sprite_child.scale += (target_scale - cur_sprite_child.scale) * 20 * delta
	target_scale = Vector2(1.5,1.5)
	if cur_index > cooking_inv_length:
		self.get_child(1).disabled = true
		visible = false
		return
	
	cur_key = Global.cooking_inventory.keys()[cur_index]
	if total_count <= 0:
		self.get_child(1).disabled = true
		visible = false
	else:
		self.get_child(1).disabled = false
		cur_sprite.play(cur_key)
		visible = true
	
func _on_mouse_entered() -> void:
	self.scale = Vector2(1.2,1.2)

func _on_mouse_exited() -> void:
	self.scale = Vector2(1,1)

func sub_inv(pick) -> void :
	total_count -= 1
	label_text.text = str(total_count)
				
func create_sprite():
	if total_count <= 0: return
	
	sub_inv(self.name)#, self.get_child(2))
	Global.cooking_scene.holding = true
	var newGrab : grabable = GRABABLE.instantiate()
	newGrab.play(self.get_child(0).animation)
	newGrab.done.connect(root.newIngre)
	newGrab.position = get_global_mouse_position()
	get_parent().add_child(newGrab)
		
func _recount():
	if !Global.cooking_inventory.has(cur_key): return
	total_count = 0
	
	for count in Global.cooking_inventory[cur_key]:
		total_count += Global.cooking_inventory[cur_key][count][0]
			
	label_text.text = str(total_count)
	
			
