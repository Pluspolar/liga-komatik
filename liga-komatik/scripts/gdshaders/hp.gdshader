shader_type canvas_item;
uniform float player_health : hint_range(0.0, 1.0);
uniform vec4 cur_modulate = vec4(0,0,0,1);

void fragment() {
	float max_y_size = SCREEN_PIXEL_SIZE.y;
	
	if (COLOR.a > 0.0) {
		float min_operation = 0.06 + abs(sin(TIME*4.0))*0.02;
		float hp_operation = 1.0-floor((1.0-UV.y)/(max_y_size+player_health));
		if (player_health <= 0.25) COLOR.a = max(min_operation, hp_operation-abs(sin(TIME*12.0))*0.4);
		else if (player_health <= 0.5) COLOR.a = max(min_operation, hp_operation-abs(sin(TIME*6.0))*0.3);
		else COLOR.a = max(min_operation, 1.0-floor((1.0-UV.y)/(max_y_size+player_health)));
		COLOR.rgb += cur_modulate.xyz;
	}
}
