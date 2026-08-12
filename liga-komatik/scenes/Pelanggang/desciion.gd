extends CanvasLayer
#@onready var dialog = $dialogue
const COOK = preload("uid://cnqh7ocygiu32")

@onready var entered = false
var char = "Random woman"
var list = ["Aku laparrrr banget, keluargaku dibunuh, cuma ini yang kupunya", "Uhhhh, aku lapar", "Aku mau porsi Jumbo"]
var times = 1
# Called when the node enters the scene tree for the first time.

func _start() -> void:
	times = 1
	Global.dialogue.add_text(list[0],15,char)
	Global.pelanggan_scene.entered = true
	$COOOOK.disabled = false #fixed a bug, don't move it
	$COOOOK.visible = true #fixed a bug, don't move it
	
#func _ready() -> void:
	#Global.dialogue.add_text(list[0],15,"Random Woman")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = get_parent().visible
	if visible and !Global.pelanggan_scene.entered:
		visible = false
		$COOOOK.disabled = true #fixed a bug, don't move it
		$COOOOK.visible = false #fixed a bug, don't move it

#func start()->void:
#	visible = true
#	entered = true
	
#	dialog.add_text(list[0],15,char)

func _on_cooook_button_down() -> void:
	print("Test")
	if Global.cur_scene != "customer" and !Global.pelanggan_scene.entered: return
	Global.change_scene_to("cooking")
	Global.cooking_target = 0.7
	
	#var change : cooks = COOK.instantiate()
	#get_tree().root.add_child(change)
	#get_tree().current_scene = change
	#var change : cooks = COOK.instantiate()
	#change.target = 0.7
	#get_tree().root.add_child(change)
	#
	#get_tree().current_scene.queue_free()
	#get_tree().current_scene = change
# 4. Free the old scene (self)
	#queue_free()

func _on_repeat_button_down() -> void:
	if Global.cur_scene != "customer" and !Global.pelanggan_scene.entered: return
	if times < list.size():
		Global.dialogue.add_text(list[times],15,char)
		times += 1

func _on_gossip_button_down() -> void:
	if Global.cur_scene != "customer" and !Global.pelanggan_scene.entered: return
	Global.dialogue.add_text("di sigma ada skibidi, kalo skibid ke sigma",15,char)
		
func done()-> void:
	Global.dialogue.add_text("YIPPPEEEEE",15)
