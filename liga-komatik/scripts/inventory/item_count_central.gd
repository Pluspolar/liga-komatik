extends CanvasLayer

@onready var hbox =	$hbox

func _ready() -> void:
	for i in range(4):
		var item_texture = TextureRect.new()
		item_texture.texture = Global.item_texture["can"]
		item_texture.stretch_mode = TextureRect.STRETCH_KEEP
		var texture_size = item_texture.texture.get_size()*hbox.scale.y
		if texture_size.y > hbox.size.y: hbox.size.y = texture_size.y
		hbox.add_child(item_texture)
		
	hbox.position.y -= hbox.size.y/2
