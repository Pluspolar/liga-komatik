extends CanvasLayer
@onready var loading_text = $loading
@onready var background = $background
@onready var dot_loading = $dot_loading
@onready var story_text = $story_text
@onready var space_text = $spasi
var loading_timer : float = 0
var dot_amount : int = 0
var cur_state = "start" #start, showing, end
var fading : bool = false
var tween : Tween

var story_array : Array = [
	"Saya tuff santoso. saya dapat menghidupi diri saya dengan menjual makanan pada gerobak sebagai pedagang kaki lima.",
	"Beberapa hari lalu, sebuah kejadian yang tidak terduga telah terjadi.",
	"Perang telah melanda tempat tinggal saya.",
	"Saya tidak dapat menghidupi diri saya tanpa memulung di banyak tempat.",
	"Serta penyakit saya yang semakin parah setiap harinya, saya perlu uang untuk menangani penyakit ini.",
	"Banyak orang diluar sana yang bertindak seenaknya karena kejadian ini.",
	"Dunia ini sedang tidak baik-baik saja."
]

func _ready() -> void:
	background.material.set_shader_parameter("fade", 1.0)

func fade_out(start_timer: float, tick : int, to_scene : String) -> void:
	fading = true
	if !Global.first_time_story: hide_text(0)
	await get_tree().create_timer(start_timer).timeout
	Global.change_scene_to(to_scene)
	for i in range(tick+1):
		background.material.set_shader_parameter("fade", 1.0-(float(i)/float(tick)))
		await get_tree().process_frame
		
	Global.is_on_ui = false
	queue_free()

func _process(delta: float) -> void:
	if dot_loading.visible: loading_dot(delta)
	elif story_text.visible: story()
		
func loading_dot(delta):
	loading_timer += delta * 10
	dot_amount = int(loading_timer) % 4 + 1
	dot_loading.text = ""
	
	for i in range(dot_amount):
		dot_loading.text += "."
	
func hide_text(transition_time : float = 0):
	loading_text.hide()
	dot_loading.hide()
	await get_tree().create_timer(transition_time).timeout
	
	story_text.show()

func story():
	if fading: return
	
	if !Global.first_time_story: 
		story_text.hide()
		fade_out(0, 30, "customer")
	
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
		Global.first_time_story = false
		fade_out(1, 30, "customer")
		
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
	
	
