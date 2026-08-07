shader_type canvas_item;
uniform vec2 pixelation = vec2(384, 384);
uniform sampler2D noise;
uniform vec2 player_pos = vec2(0.5, 0.5);

void fragment() {
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	
	vec2 pixel_uv = floor(UV * pixelation) / pixelation;
	vec2 uv_mixed = mix(pixel_uv, UV, 0.5);
	
	vec2 new_player_pos = player_pos;
	new_player_pos.x *= aspect;
	uv_mixed.x *= aspect;
	
	vec2 noise_scroll = fract(uv_mixed + TIME * 0.03);
	vec4 noise_a = texture(noise, noise_scroll);
	float dist = distance(new_player_pos, uv_mixed)*7.5;

	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = vec3(0.0);
	COLOR.a = mix(noise_a.r, dist, 0.7)+0.1;
	if (dist <= 0.4) COLOR.a -= (0.4-dist)*0.75;
}