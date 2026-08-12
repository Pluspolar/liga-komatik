extends Area2D
const GRABABLE = preload("uid://0q5f1qfe1crj")
var cur_key = null
var cur_sprite : Object
var total_count : int = 1
var label_text : Object

@onready var s1 = $"../0/AnimatedSprite2D1"
@onready var s2 = $"../1/AnimatedSprite2D2"
@onready var s3 = $"../2/AnimatedSprite2D3"
@onready var s4 = $"../3/AnimatedSprite2D4"
@onready var s5 = $"../4/AnimatedSprite2D5"
@onready var s6 = $"../5/AnimatedSprite2D6"
@onready var root = $".."
@onready var Inventory: Dictionary = {
	"0"  : 10,
	"1"  : 10,
	"2"  : 10,
	"3"  : 10,
	"4"  : 10,
	"5"  : 10
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.get_child(2).text = str(Inventory[self.name])
	label_text = self.get_child(2)
	collision_layer = 256
	add_to_group("cooking_item_list")
	
	cur_sprite = self.get_child(0)
	var _sprite_frames = cur_sprite.sprite_frames
	var cur_sprite_texture = _sprite_frames.get_frame_texture(cur_sprite.animation, 0).get_size()
	cur_sprite.position.y -= cur_sprite_texture.y/4
	#print(cur_sprite_texture)
	#print()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cooking_inv_length : int = Global.cooking_inventory.size()-1
	var cur_index = int(self.name)
	if cur_index > cooking_inv_length:
		#cur_key = null
		self.get_child(1).disabled = true
		visible = false
		return
	
	cur_key = Global.cooking_inventory.keys()[cur_index]
	#if Global.cooking_inventory.has(cur_key): 
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
	#Inventory[pick] -= 1
	total_count -= 1
	label_text.text = str(total_count)
	
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if false and Global.cur_scene == "cooking" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var list = [s1,s2,s3,s4,s5,s6]
		for i in list:
			if self.get_child(0) == i:
				sub_inv(self.name)#, self.get_child(2))
				Global.cooking_scene.holding = true
				var newGrab : grabable = GRABABLE.instantiate()
				newGrab.play(i.animation)
				newGrab.done.connect(root.newIngre)
				newGrab.position = get_global_mouse_position()
				get_parent().add_child(newGrab)
				if Inventory[self.name] < 1:
					queue_free()
				
func create_sprite():
	if total_count <= 0: return
	
	sub_inv(self.name)#, self.get_child(2))
	Global.cooking_scene.holding = true
	var newGrab : grabable = GRABABLE.instantiate()
	newGrab.play(self.get_child(0).animation)
	newGrab.done.connect(root.newIngre)
	newGrab.position = get_global_mouse_position()
	get_parent().add_child(newGrab)
	
	#if cur_key != null : print(Global.cooking_inventory[cur_key])
	#if Inventory[self.name] < 1:
	#	queue_free()
		
func _recount():
	if !Global.cooking_inventory.has(cur_key): return
	total_count = 0
	
	for count in Global.cooking_inventory[cur_key]:
		total_count += Global.cooking_inventory[cur_key][count][0]
			
	label_text.text = str(total_count)
	
			
