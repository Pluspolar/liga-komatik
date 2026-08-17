extends Node2D
@onready var dialog = $dialogue
var radio_text : Array = [
"Tentara-tentara mulai melandas di daerah IKN, pesawat AU mulai melewati langit IKN",
"Sekolah muhhamdiyah 67 kena bomb di hari ini. 420 dari 1260 siswa-siswi ditemukan wafat.",
"Negara musuh mengebom pipa Sumber Air Jaya, IKN tidak memiliki sumber air yang lain, Pemerintah mengirim truk air keluar dalam IKN",
"Pemerintah menyatakan Tentara musuh mulai melandas di pesisir-pesisir kalimantan, jendral Sutarjo menyatan bahwa IKN terlindungi",
"Jaringan listrik dan telekomunikasi di pusat IKN lumpuh total akibat serangan rudal yang menargetkan Gardu Induk Sepaku.",

"Jembatan Pulau Balang dihantam bom jelajah; jalur evakuasi utama darat menuju Balikpapan resmi terputus.",

"RSU Sepaku menyatakan situasi krisis massal, lebih dari 800 korban luka-luka memadati lorong rumah sakit di tengah keterbatasan pasokan medis.",

"Sistem pertahanan udara TNI berhasil menembak jatuh dua pesawat tempur musuh yang mencoba menembus zona udara Istana Garuda.",

"Presiden mengumumkan pengalihan pusat komando darurat ke lokasi rahasia setelah Kompleks Kementerian Hankam mengalami kerusakan struktur akibat artileri.",

"Batalyon Marinir dikerahkan ke muara Sungai Mahakam untuk membendung penetrasi armada amfibi musuh yang mencoba masuk dari arah pantai.",

"Pasukan gabungan TNI dan sukarelawan lokal mendirikan garis pertahanan terakhir di Km 38 Tol Balikpapan-Samarinda."
]
func radio() -> int :
	return Global.cur_day % radio_text.size()
# Called when the node enters the scene tree for the first time.
func start() -> void:
	dialog.add_text(radio_text[radio()], 15.0, "Radio")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_down() -> void:
	pass
