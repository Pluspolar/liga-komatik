extends Node2D

var tile_set
var corner_spot

func _ready() -> void:
	pass

	
	
func _create_cell():
	tile_set = $TileMapLayer.local_to_map(corner_spot)
	#print(tile_set)
	for i in range(-2, 18):
		for j in range(-2, 11):
			var place_tile = tile_set + Vector2i(i,j)
			if !$TileMapLayer.get_cell_tile_data(place_tile): 
				$TileMapLayer.set_cell(place_tile, 1, Vector2i(randi_range(0,1),randi_range(0,1)), 0)

func _process(delta: float) -> void:
	corner_spot = ($Camera2D.global_position) - (get_viewport_rect().size/2)
	#print(corner_spot)
	_create_cell()
	$Camera2D.position += 5*Vector2(int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")), int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")))
	
