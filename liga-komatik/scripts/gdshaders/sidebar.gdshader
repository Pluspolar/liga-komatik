shader_type canvas_item;
uniform sampler2D noise_1;
uniform sampler2D noise_2;
uniform sampler2D noise_combine;
uniform vec2 center_pos;

void fragment() {
	vec2 pixel_uv = floor(UV*128.0) / 128.0;
	
	vec2 uv_fract_1 = fract(pixel_uv + TIME * 0.0115);
	vec2 uv_fract_2 = fract(pixel_uv + TIME * 0.0185);
	vec2 uv_combine_fract = fract(pixel_uv - TIME * 0.045);
	
	//vec2 pixel_uv_1 = floor(uv_fract_1*128.0) / 128.0;
	//vec2 pixel_uv_2 = floor(uv_fract_2*128.0) / 128.0;
	//vec2 pixel_combine_fract = floor(uv_combine_fract*128.0) / 128.0;
	
	float noise_combine_uv = texture(noise_combine, uv_combine_fract).r*0.5;
	
	float noise_a_1 = texture(noise_1, uv_fract_1).r * noise_combine_uv;
	float noise_a_2 = texture(noise_2, uv_fract_2).r * (0.5-noise_combine_uv);
	
	float cur_distance = pow(distance(UV.x, center_pos.x), 1.25) * 11.0;
	float noise_total = mix(noise_a_1*8.0, noise_a_2*8.0, 0.5) - cur_distance;
	
	
	float noise_total_distance = mix(0.4/cur_distance, noise_total, 0.7);
	COLOR.a = noise_total_distance;
	COLOR.rgb = vec3(0.0);
	//COLOR.a *= 0.8;
	//if (COLOR.a < 0.0) COLOR.a = 0.0;
	//COLOR.a += 0.4;
	
}
