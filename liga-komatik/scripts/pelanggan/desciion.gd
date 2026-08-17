extends CanvasLayer
const COOK = preload("uid://cnqh7ocygiu32")

@onready var entered = false
var _char = "Woman"
var times = 1
# Called when the node enters the scene tree for the first time.

var dialogue_list = {
	"woman_1" : 
		["Aku gak punya banyak, jadi aku tak perlu banyak", 
		"Uhhh medium", 
		"aku mau porsi medium"],

	"woman_2" : 
		["Suami ku sakit", 
		"kita tidak punya banyak uang kita ambil apa adanya", 
		"Kasih yang kamu bisa kasi kumohon"],
		
	"man_1" : 
		["Aku [wave]laparrrr[/wave] banget, cuma ini yang kupunya",
		"Uhhhh, aku lapar", 
		"Aku mau porsi Jumbo"],
		
	"man_2" : 
		["Aku mo ke medan, kasi yang cukup buat di medan", 
		"Orang yang banyak gerak butuh seberapa banyak menurutmu", 
		"Porsi Jumbo"],
		
	"man_3" : 
		["Mmmmmm [wave]lapaaar[/wave], butuh makaaan", 
		"[shake]AKU BUTUH MAKAAAAN", 
		"Aku mau porsi [wave]JUMBO[/wave]"],
}

var dialogue_sound_list := {
	"woman_1" : ["Woman1Speech1", "Woman1Speech2", "Woman1Speech3"],
	"woman_2" : ["Woman2Speech1", "Woman2Speech2", "Woman2Speech3"],
	"man_1" : ["Man1Speech1", "Man1Speech2", "Man1Speech3"],
	"man_2" : ["Man2Repeat1", "ManRepeat2", "Man2Repeat3"],
	"man_3" : ["Man3Speech1", "Man3Speech2", "Man3Speech3"],
}

var gossip_list := {
	"woman_1" : ["Woman1Gossip"],
	"woman_2" : ["Woman2Gossip"],
	"man_1" : ["Man1Gossip"],
	"man_2" : ["Man2Gossip"],
	"man_3" : ["Man3Gossip"],
}

var thank_list := {
	"woman_1" : ["Woman1Thanks1", "Woman1Thanks2", "Woman1Thanks3"],
	"woman_2" : ["Woman2Thanks1"],
	"man_1" : ["Man1Thanks1", "Man1Thanks2"],
	"man_2" : ["Man2Thanks", "MakasihMan2", ""],
	"man_3" : [],
}

var no_thank_list := {
	"woman_1" : ["Woman1Sorry1", "Woman1Sorry2"],
	"woman_2" : ["Woman2Thanks2"],
	"man_1" : ["Man1Nothanks1", "Man1Nothanks2"],
	"man_2" : ["NoThanksMan2"],
	"man_3" : [],
}

var char_convert = {
	"woman_1" : "Woman",
	"woman_2" : "Woman",
	"man_1" : "Man",
	"man_2" : "Man",
	"man_3" : "Man",
}

var dialogue_gossips = {
	"woman_1" : "Sepupu ku kena keracunan karena tentara musuh meracuni sumber air kampung kami",
	"woman_2" : "Sekolah anakku kena bomb kemaren.... anakku terbunuh juga",
	"man_1" : "Dunia ini sedang tidak baik-baik saja",
	"man_2" : "Kemaren teman medan ku menginjak ranjau, Pernakah kamu mendengar teriakan seseorang tanpa paru paru",
	"man_3" : "Aku kehilangan kerjaku kemaren gara-gara pabrik ku di bomb, beruntung kamu kaki lima",
}

var dialogue_done = {
	"woman_1" : [
		["Terimakasih", "Terimakasih Banyak", "Makasih"], 
		["Sepertinya ini kurang", "Kurang deh"]],
	
	"woman_2" : [
		["Terimakasih Banyak"], 
		["Terimakasih"]],
		
	"man_1" : [
		["Lesgoo Makasih Bang", "Makasih Banyak"], 
		["Kurang ini", "Kurang, bang"]],
		
	"man_2" : [
		["Makasih", "Makasih Bang", "[shake]MERDEKA"], 
		["Eh gak dikit ini?"]],
		
	"man_3" : [
		["[wave]MAKANNN", "[wave]YESSSS"], 
		["[shake]INI APAAAN?", "[shake]AKU MAKAN KAMU"]],
}
var char_cooking_target = {}
# < 0.05: Tidak ada, 
#[0.05, 0.3): sedikit, 
#[0.3, 0.65): medium, 
#>= 0.65: jumbo

func rand_cooking_target():
	char_cooking_target = {
	"woman_1" : randf_range(0.35, 0.6),
	"woman_2" : 0.05,
	"man_1" : randf_range(0.65, 0.7),
	"man_2" : randf_range(0.65, 0.725),
	"man_3" : randf_range(0.7, 0.8),
}


func _start() -> void:
	times = 1
	_char = char_convert[Global.pelanggan_scene.cur_pelanggan]
	if Global.dialogue.visible: Global.skip_dialogue = true
	Global.dialogue.add_text(dialogue_list[Global.pelanggan_scene.cur_pelanggan][0], 15, _char)
	if !dialogue_sound_list[Global.pelanggan_scene.cur_pelanggan].is_empty():
		Global.dialogue_play(dialogue_sound_list[Global.pelanggan_scene.cur_pelanggan][0])
	Global.pelanggan_scene.entered = true
	$COOOOK.disabled = false #fixed a bug, don't move it
	$COOOOK.visible = true #fixed a bug, don't move it
	$Explore.disabled = false #fixed a bug, don't move it
	$Explore.visible = true #fixed a bug, don't move it

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = get_parent().visible
	if visible and !Global.pelanggan_scene.entered:
		visible = false
		$COOOOK.disabled = true #fixed a bug, don't move it
		$COOOOK.visible = false #fixed a bug, don't move it
		$Explore.disabled = true #fixed a bug, don't move it
		$Explore.visible = false #fixed a bug, don't move it

func _on_explore_button_down() -> void:
	Global.change_scene_to("outside")

func _on_cooook_button_down() -> void:
	if Global.cur_scene != "customer" and !Global.pelanggan_scene.entered: return
	rand_cooking_target()
	if Global.pelanggan_scene.read_repeat: Global.cooking_scene.done_label.text = "SELESAI\nAWAL"
	else: Global.cooking_scene.done_label.text = "SELESAI"
	
	Global.change_scene_to("cooking")
	Global.target_nutrition = 0
	Global.cooking_target = char_cooking_target[Global.pelanggan_scene.cur_pelanggan]
	
func _on_repeat_button_down() -> void:
	if Global.cur_scene != "customer" and !Global.pelanggan_scene.entered: return
	var cur_dialogue_list = dialogue_list[Global.pelanggan_scene.cur_pelanggan]
	if times < cur_dialogue_list.size():
		if Global.dialogue.visible: Global.skip_dialogue = true
		Global.dialogue.add_text(dialogue_list[Global.pelanggan_scene.cur_pelanggan][times],15,_char)
		if times < dialogue_sound_list[Global.pelanggan_scene.cur_pelanggan].size():
			Global.dialogue_play(dialogue_sound_list[Global.pelanggan_scene.cur_pelanggan][times])
		times += 1
		
		if times >= cur_dialogue_list.size(): 
			Global.pelanggan_scene.read_repeat = true

func _on_gossip_button_down() -> void:
	if Global.cur_scene != "customer" and !Global.pelanggan_scene.entered: return
	if Global.dialogue.visible: Global.skip_dialogue = true
	Global.dialogue.add_text(dialogue_gossips[Global.pelanggan_scene.cur_pelanggan],15,_char)
	if !gossip_list[Global.pelanggan_scene.cur_pelanggan].is_empty():
		Global.dialogue_play(gossip_list[Global.pelanggan_scene.cur_pelanggan][0])
	
func done()-> void:
	if Global.target_nutrition >= Global.cooking_target:
		var cur_dialogue = dialogue_done[Global.pelanggan_scene.cur_pelanggan][0]
		var cur_dialogue_index = randi_range(0, cur_dialogue.size()-1)
		cur_dialogue = cur_dialogue[cur_dialogue_index]
		Global.dialogue.add_text(cur_dialogue, randf_range(12, 20), _char)
		if cur_dialogue_index < thank_list[Global.pelanggan_scene.cur_pelanggan].size():
			Global.dialogue_play(thank_list[Global.pelanggan_scene.cur_pelanggan][cur_dialogue_index])
		
		var target_nutri_sqr = pow(1+Global.target_nutrition, 2)
		Global.spawn_coins(ceil(target_nutri_sqr*7.5*(1+Global.cooking_target)))
	else:
		var cur_dialogue = dialogue_done[Global.pelanggan_scene.cur_pelanggan][1]
		var cur_dialogue_index = randi_range(0, cur_dialogue.size()-1)
		cur_dialogue = cur_dialogue[cur_dialogue_index]
		Global.dialogue.add_text(cur_dialogue, randf_range(12, 20), _char)
		
		if cur_dialogue_index < no_thank_list[Global.pelanggan_scene.cur_pelanggan].size():
			Global.dialogue_play(no_thank_list[Global.pelanggan_scene.cur_pelanggan][cur_dialogue_index])
			
		var target_nutri_change = pow(1+Global.target_nutrition, 1.75)
		Global.spawn_coins(ceil((target_nutri_change-1)*5))
