extends Node2D

var radio_text : Array = [
"Tentara-tentara mulai melandas di daerah IKN, pesawat AU mulai melewati langit IKN",
"Sekolah 67 kena bomb di hari ini. 420 dari 1260 siswa-siswi ditemukan wafat.",
"Negara musuh mengebom pipa air, IKN tidak memiliki sumber air yang lain, Pemerintah mengirim truk air keluar dalam IKN",
"Pemerintah menyatakan Tentara musuh mulai melandas di pesisir-pesisir kalimantan, jendral Sutarjo menyatan bahwa IKN terlindungi",
"Jaringan listrik dan telekomunikasi di pusat IKN lumpuh total akibat serangan rudal yang menargetkan Gardu Induk Sepaku.",

"Jembatan Pulau Balang dihantam bom jelajah; jalur evakuasi utama darat menuju Balikpapan resmi terputus.",

"RSU Sepaku menyatakan situasi krisis massal, lebih dari 800 korban luka-luka memadati lorong rumah sakit di tengah keterbatasan pasokan medis.",

"Sistem pertahanan udara TNI berhasil menembak jatuh dua pesawat tempur musuh yang mencoba menembus zona udara Istana Garuda.",

"Presiden mengumumkan pengalihan pusat komando darurat ke lokasi rahasia setelah Kompleks Kementerian Hankam mengalami kerusakan struktur akibat artileri.",

"Batalyon Marinir dikerahkan ke muara Sungai Mahakam untuk membendung penetrasi armada amfibi musuh yang mencoba masuk dari arah pantai.",

"Pasukan gabungan TNI dan sukarelawan lokal mendirikan garis pertahanan terakhir di Km 38 Tol Balikpapan-Samarinda."
]

func _ready() -> void:
	Global.day_start = self

func radio() -> int :
	return Global.cur_day-1 % radio_text.size()
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
