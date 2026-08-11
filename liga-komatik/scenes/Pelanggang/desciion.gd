extends CanvasLayer
@onready var dialog = $dialogue

var COOK = load("uid://cnqh7ocygiu32")
@onready var entered = false
var char = "Random woman"
var list = ["Aku laparrrr banget, keluargaku dibunuh, cuma ini yang kupunya", "Uhhhh, aku lapar", "Aku mau porsi Jumbo"]
var times = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start()->void:
	visible = true
	entered = true
	
	dialog.add_text(list[0],15,char)

func _on_cooook_button_down() -> void:
	if entered:
		var change : cooks = COOK.instantiate()
		change.target = 0.7
		get_tree().root.add_child(change)
		
		get_tree().current_scene.queue_free()
		get_tree().current_scene = change
func _on_repeat_button_down() -> void:
	if entered:
		if times < list.size():
			dialog.add_text(list[times],15,char)
			times += 1

func _on_gossip_button_down() -> void:
	if entered:
		dialog.add_text("di sigma ada skibidi, kalo skibid ke sigma",15,char)
	

func done()-> void:
	dialog.add_text("YIPPPEEEEE",15)
