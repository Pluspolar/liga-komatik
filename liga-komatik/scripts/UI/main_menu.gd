extends CanvasLayer

var is_button_hovering : bool = false
@onready var vignette = $vignette


func _process(delta: float) -> void:
	if is_button_hovering: 
		is_button_hovering = false
		vignette.modulate += (Color(1,1,1,0.5)-vignette.modulate) * 10 * delta
	else: vignette.modulate += (Color(1,1,1,0)-vignette.modulate) * 10 * delta
