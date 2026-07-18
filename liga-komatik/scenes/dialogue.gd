extends CanvasLayer
@onready var text = $MarginContainer/MarginContainer2/HBoxContainer/text
@onready var end_text = $MarginContainer/MarginContainer2/HBoxContainer/end
@onready var char_text = $char
var tween = create_tween()
var text_array: Array = []

enum state {
	READY,
	TALKING,
	END
}

@onready var cur_state = state.READY
var char_text_ : String

func add_text(_text: String, speed: float = 10, _char: String = ""):
	if _char != '': char_text_ = _char
	text_array.append(["\n" + _text, speed, char_text_])

func _ready() -> void:
	add_text("So gurt", 10, "name")
	add_text("So umm, [shake]YOGURT[/shake] town has been decimated, good luck", 10)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		add_text("So gurt", 10, "Yogurt Monster")
	match cur_state:
		state.READY:
			if !text_array.is_empty(): 
				show()
				display_text()
			else: hide()
		state.TALKING:
			if Input.is_action_just_pressed("ui_accept") or text.visible_ratio == 1:
				text.visible_ratio = 1.0
				end_text.visible_ratio = 1.0
				tween.stop()
				cur_state = state.END
		state.END:
			if Input.is_action_just_pressed("ui_accept"):
				text.visible_ratio = 0
				end_text.visible_ratio = 0
				cur_state = state.READY

func display_text():
	text.text = text_array[0][0]
	char_text.text = text_array[0][2]
	text.visible_ratio = 0
	end_text.visible_ratio = 0
	var text_len = text.get_total_character_count()
	tween.tween_property(text, "visible_characters", text_len, text_len / text_array[0][1])
	tween.play()
	text_array.remove_at(0)
	cur_state = state.TALKING	

	
