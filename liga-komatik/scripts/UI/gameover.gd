extends CanvasLayer
@onready var background = $background
@onready var story_text = $story_text
@onready var space_text = $spasi
var loading_timer : float = 0
var dot_amount : int = 0
var cur_state = "start" #start, showing, end
var fading : bool = false
var tween : Tween

var story_array : Array = [
	"Tuff santoso menghembuskan nafas terakhirnya di tengah malam.",
	"Akhirnya, ia menemukan kedamaian.",
]

func _ready() -> void:
	hide_text(1)

func fade_out(start_timer: float) -> void:
	fading = true
	await get_tree().create_timer(start_timer).timeout
		
	Global.is_reset = true

func _process(delta: float) -> void:
	if story_text.visible: story()
	
func hide_text(transition_time : float = 0):
	await get_tree().create_timer(transition_time).timeout
	
	story_text.show()

func story():
	if fading: return
	
	elif cur_state == "start" and !story_array.is_empty():
		story_text.text = story_array[0]
		story_text.visible_characters = 0
		space_text.visible = false
		
		var text_len = story_text.get_total_character_count()
		tween = create_tween()
		tween.tween_property(story_text, "visible_characters", text_len, text_len / 20)
		tween.play()
		story_array.remove_at(0)
		cur_state = "showing"
		
	elif cur_state == "start" and story_array.is_empty():
		fade_out(1)
				
	elif cur_state == "showing":
		if Input.is_action_just_pressed("ui_accept") or story_text.visible_ratio == 1:
			tween.stop()
			story_text.visible_ratio = 1
			space_text.visible = true
			cur_state = "end"
			
	elif cur_state == "end":
		if Input.is_action_just_pressed("ui_accept"):
			space_text.visible = false
			story_text.visible_ratio = 0
			cur_state = "start"
	
	
