extends Area2D
const GRABABLE = preload("uid://0q5f1qfe1crj")
@onready var s1 = $"../1/AnimatedSprite2D1"
@onready var s2 = $"../2/AnimatedSprite2D2"
@onready var s3 = $"../3/AnimatedSprite2D3"
@onready var s5 = $"../5/AnimatedSprite2D5"
@onready var s6 = $"../6/AnimatedSprite2D6"
@onready var s4 = $"../4/AnimatedSprite2D4"
@onready var root = $".."
@onready var Inventory: Dictionary = {
	"1"  : 10,
	"2"  : 10,
	"3"  : 10,
	"4"  : 10,
	"5"  : 10,
	"6"  : 10
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_child(2).text = str(Inventory[self.name])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	self.scale = Vector2(1.2,1.2)

func _on_mouse_exited() -> void:
	self.scale = Vector2(1,1)

func sub_inv(pick, label) -> void :
	Inventory[pick] -= 1
	label.text = str(Inventory[pick])
	



func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var list = [s1,s2,s3,s4,s5,s6]
		for i in list:
			if self.get_child(0) == i:
				sub_inv(self.name, self.get_child(2))
				root.holding = true
				var newGrab : grabable = GRABABLE.instantiate()
				newGrab.play(i.animation)
				newGrab.done.connect(root.newIngre)
				newGrab.position = get_global_mouse_position()
				get_parent().add_child(newGrab)
				if Inventory[self.name] < 1:
					queue_free()
				
				
