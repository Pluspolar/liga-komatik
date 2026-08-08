extends RigidBody2D
class_name foods
@onready var time = $Timer
@export var gravity_strength: float = 400.0
@onready var spatula  = $"../Spatula"
@onready var wajan = $"../wajan"
@onready var sprite = $AnimatedSprite2D

@onready var shapes: Dictionary = {
	"sarden": $sarden,
	"rumput": $rumput,
	"kornet": $kornet,
	"udang": $udang,
	"ubi": $ubi
}
const cookTime = 10
signal done(nutrition)
@export var nutrition = 0.5
@export var timePass = 0


func _ready() -> void:
	# Disable the default global Y-down gravity on this body
	gravity_scale = 0.0
	
	wajan.body_exited.connect(dirty)
	wajan.body_entered.connect(mulai)
	
func dirty(junk)-> void:
	if junk == self:
		queue_free()

func _physics_process(delta: float) -> void:
	
	var center_of_screen: Vector2 = get_viewport_rect().size / 2.0
	var direction_to_center: Vector2 = global_position.direction_to(center_of_screen)
	apply_central_force(direction_to_center * gravity_strength)

func _on_timer_timeout() -> void:
	if timePass > cookTime:
		done.emit(nutrition)
		queue_free()
		
	else: 
		timePass += 1
		print("continue")



func mulai(junk):
	if junk == self: 
		time.start()
		print("start")

func _on_body_entered(body: Node) -> void:
	
	if body == spatula:
		timePass += 1
		print("kena")
		
func activate(pick) -> void :
	for shape_names in shapes:
		print(pick)
		shapes[shape_names].disabled = (shape_names != pick)
