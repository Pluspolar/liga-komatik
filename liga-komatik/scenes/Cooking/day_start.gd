extends Node2D

var radio_text : Array = [
"Tentara-tentara mulai melandas di daerah IKN, pesawat AU mulai melewati langit IKN",
"Sekolah 67 kena bomb di hari ini. 420 dari 1260 siswa-siswi ditemukan wafat.",
"Negara musuh mengebom pipa-pipa air IKN, kita tidak memiliki sumber air yang lain.",
"Kami menyatakan Tentara musuh mulai melandas di pesisir kalimantan, jendral Sutarjo menyatan bahwa IKN terlindungi",
"Jaringan listrik di pusat IKN lumpuh total akibat rudal yang Mengenai Trafo Induk.",
"Jembatan Pulau Skibidi dihantam bom. Jalur evakuasi utama darat menuju IKN resmi terputus.",
"Jendral Sutarjo menyatakan situasi krisis massal, lebih dari 800 korban luka-luka memadati lorong rumah sakit.",
"Sistem pertahanan udara TNI berhasil menembak jatuh dua pesawat tempur musuh yang mencoba menembus zona udara IKN.",
"Presiden mengumumkan pengalihan pusat komando darurat ke lokasi rahasia setelah Kompleks Kementerian Sigma kena rudal.",
"Batalyon Marinir dikirim untuk membendung penetrasi armada amfibi musuh yang mencoba masuk dari arah pantai.",
"Pasukan gabungan TNI dan sukarelawan lokal mendirikan garis pertahanan terakhir di Km 38 Tol Charlie-Kirk."
]

func _ready() -> void:
	Global.day_start = self

func radio() -> int :
	if Global.is_captured: 
		Global.is_captured = false
		return Global.cur_day-2 % radio_text.size()
	else: return Global.cur_day-1 % radio_text.size()

# Called when the node enters the scene tree for the first time.
func _start() -> void:
	global_position = Global.cur_cam.global_position - Global.viewport_tree.size/2
	$start.hide()
	show()
	await get_tree().create_timer(1).timeout
	$start.show()
	Global.dialogue.add_text(radio_text[radio()], 15.0, "Radio")

func _on_start_button_down() -> void:
	Global.is_on_ui = false
	hide()
	Global.change_scene_to("central_inventory")
