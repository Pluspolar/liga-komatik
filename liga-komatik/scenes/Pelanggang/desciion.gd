extends CanvasLayer
@onready var dialog = $dialogue
const COOK = preload("uid://cnqh7ocygiu32")

var list = ["Aku laparrrr banget, keluargaku dibunuh, cuma ini yang kupunya", "Uhhhh, aku lapar", "Aku mau porsi Jumbo"]
var times = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog.add_text(list[0],15,"Random Woman")
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cooook_button_down() -> void:
	
	var change : cooks = COOK.instantiate()
	get_tree().root.add_child(change)
	get_tree().current_scene = change

# 4. Free the old scene (self)
	queue_free()

func _on_repeat_button_down() -> void:
	if times < list.size():
		dialog.add_text(list[times],15,"Random Woman")
		times += 1
	
	
	

func _on_gossip_button_down() -> void:
	dialog.add_text("di sigma ada skibidi, kalo skibid ke sigma",15,"Random Woman")
