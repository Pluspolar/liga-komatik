extends RigidBody2D
class_name foods
@onready var time = $Timer
@export var gravity_strength: float = 400.0
@onready var spatula  = $"../Spatula"
@onready var wajan = $"../wajan"
@onready var sprite = $AnimatedSprite2D
@onready var shapes: Dictionary = {
	"belalang": $belalang,
	"can": $can,
	"kornet": $kornet,
	"mie": $mie,
	"rumput": $rumput,
	"sarden": $sarden,
	"sawdust": $sawdust,
	"sosis": $sosis,
	"ubi": $ubi,
	"udang": $udang,
	"worm": $worm,
}

const cookTime = 10
signal done(nutrition)
var nutrition : float
@export var timePass = 0


func _ready() -> void:
	if !Global.cooking_obj.has(self): Global.cooking_obj.append(self)
	# Disable the default global Y-down gravity on this body
	gravity_scale = 0.0
	
	wajan.body_exited.connect(dirty)
	wajan.body_entered.connect(mulai)
	
func dirty(junk)-> void:
	if junk == self:
		if Global.cooking_obj.has(self): Global.cooking_obj.erase(self)
		Global.sound_play("junk")
		queue_free()

func _physics_process(delta: float) -> void:
	var center_of_screen: Vector2 = get_viewport_rect().size / 2.0
	var direction_to_center: Vector2 = global_position.direction_to(center_of_screen)
	apply_central_force(direction_to_center * gravity_strength)

func _on_timer_timeout() -> void:
	if timePass > cookTime:
		done.emit(nutrition)
		if Global.cooking_obj.has(self): Global.cooking_obj.erase(self)
		queue_free()
	else: 
		timePass += 1

func mulai(junk):
	if junk == self: 
		Global.sound_play("sizzling")
		time.start()

func _on_body_entered(body: Node) -> void:
	if body == spatula:
		timePass += 1
		
func activate(pick) -> void :
	shapes[pick].disabled = false
	shapes[pick].scale = Vector2(1.5,1.5)
	shapes[pick].show()
