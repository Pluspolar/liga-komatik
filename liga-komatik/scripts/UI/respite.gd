extends CanvasLayer

@onready var background = $background
@onready var medicine_button = $buy_medicine
@onready var medicine_cost = $medicine_cost
@onready var arang_button = $buy_arang
@onready var arang_cost = $arang_cost
@onready var continue_button = $continue
var tween : Tween
var gameover = preload("res://scenes/UI/gameover.tscn")

@onready var text_array : Dictionary = {
	"day" : [$day, Global.cur_day, "HARI "],
	"customer" : [$customer, Global.customer_done, "Pelanggan Dilayani: "],
	"item_picked_up" : [$item_picked_up, Global.item_pickup_count, "Barang/Bahan yang\ndidapatkan: "],
	"item_cooked" : [$item_cooked, Global.item_cooked, "Bahan yang dimasak: "],
	"distance" : [$distance, float(int(Global.distance_traveled*10000))/10000, "Jarak yang dituju: "],
	"coins_gained" : [$coins_gained, Global.coins_earned, "Uang yang didapatkan: "],
}

@onready var medicine_array : Array = [
	medicine_button, medicine_cost
]	

@onready var arang_array : Array = [
	arang_button, arang_cost
]

func fade_in():
	Global.is_on_ui = true
	for i in range(31):
		background.material.set_shader_parameter("fade", (float(i)/float(30)))
		await get_tree().process_frame
		
	_start()
	
func fade_out():
	if Global.days_left <= 0:
		get_tree().current_scene.add_child(gameover.instantiate())
		queue_free()
		
	Global.day_start._start()
	
	for i in range(31):
		background.material.set_shader_parameter("fade", 1.0-(float(i)/float(30)))
		await get_tree().process_frame

	queue_free()

func _ready() -> void:
	fade_in()
	
func _start():
	$separator.show()
	continue_button.button_down.connect(_button_continue)
	arang_button.button_down.connect(_arang_button)
	medicine_button.button_down.connect(_medicine_button)
	for obj in text_array:
		text_array[obj][0].text = text_array[obj][2]
		text_array[obj][0].text += str(text_array[obj][1])
		if obj == "distance": text_array[obj][0].text += " KM"
		if obj == "day" and Global.is_captured: text_array[obj][0].text += " (TERTANGKAP)"
		tween = create_tween()
		text_array[obj][0].visible_ratio = 0
		text_array[obj][0].show()
		tween.tween_property(text_array[obj][0], "visible_ratio", 1, randf_range(1.5, 4))
		tween.play()
	await get_tree().create_timer(randf_range(1.2, 2)).timeout
	if Global.coins >= 100: for obj in medicine_array: obj.show()
	if Global.coins >= 30: for obj in arang_array: obj.show()
		
	await get_tree().create_timer(randf_range(1.5, 3)).timeout
	continue_button.show()
	
func hide_all():
	for obj in text_array:
		text_array[obj][0].hide()
	for obj in medicine_array: obj.hide()
	for obj in arang_array: obj.hide()
		
	$separator.hide()
	continue_button.hide()
	
func _button_continue():
	hide_all()
	if Global.is_captured:
		Global.heart.change_day(-2)
		Global.cur_day += 2
	else: 
		Global.heart.change_day(-1)
		Global.cur_day += 1
	Global.stats_reset()
	await get_tree().create_timer(1.0).timeout
	fade_out()
	
func _medicine_button(): 
	for obj in medicine_array: obj.hide()
	if Global.coins >= 100: Global.days_left += 2
	Global.coin_icon.change_coin(-100)
	
func _arang_button(): 
	for obj in arang_array: obj.hide()
	if Global.coins >= 30: Global.days_left += 0.5
	Global.coin_icon.change_coin(-30)
	
