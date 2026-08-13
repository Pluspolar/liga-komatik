extends RigidBody2D
class_name foods
@onready var time = $Timer
@export var gravity_strength: float = 400.0
@onready var spatula  = $"../Spatula"
@onready var wajan = $"../wajan"
@onready var sprite = $AnimatedSprite2D
#first one is the collision, seccond nutrition value
#@onready var shapes: Dictionary = {
#	"sarden": [$sarden, 70],
#	"rumput": [$rumput, 10],
#	"kornet": [$kornet, 100],
#	"udang": [$udang, 40],
#	"ubi": [$ubi, 50]
#}
@onready var shapes: Dictionary = {
	"belalang": $sarden,
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
#@export var nutrition : float = 0.5
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
		#print("continue")

func mulai(junk):
	if junk == self: 
		time.start()
		#print("start")

func _on_body_entered(body: Node) -> void:
	if body == spatula:
		timePass += 1
		#print("kena")
		
func activate(pick) -> void :
	#shapes[pick][0].disabled = false
	shapes[pick].disabled = false
	shapes[pick].scale = Vector2(1.5,1.5)
	shapes[pick].show()
	#nutrition = shapes[pick][1]
	#nutrition = Global._item_nutrition[pick][0][0][1]
	#print(nutrition)
