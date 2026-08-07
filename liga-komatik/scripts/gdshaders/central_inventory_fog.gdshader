shader_type canvas_item;
uniform sampler2D noise_1;
uniform sampler2D noise_2;
uniform sampler2D noise_combine;
uniform vec2 center_pos;

void fragment() {
	vec2 pixel_uv = floor(UV*128.0) / 128.0;
	
	vec2 uv_fract_1 = fract(pixel_uv + TIME * 0.01);
	vec2 uv_fract_2 = fract(pixel_uv + TIME * 0.02);
	vec2 uv_combine_fract = fract(pixel_uv - TIME * 0.035);
	
	//vec2 pixel_uv_1 = floor(uv_fract_1*128.0) / 128.0;
	//vec2 pixel_uv_2 = floor(uv_fract_2*128.0) / 128.0;
	//vec2 pixel_combine_fract = floor(uv_combine_fract*128.0) / 128.0;
	
	float noise_combine_uv = texture(noise_combine, uv_combine_fract).r*1.1;
	
	float noise_a_1 = texture(noise_1, uv_fract_1).r * noise_combine_uv;
	float noise_a_2 = texture(noise_2, uv_fract_2).r * (1.1-noise_combine_uv);
	
	float noise_total = mix(noise_a_1*3.5, noise_a_2*3.5, 0.5);
	COLOR.a = noise_total;
}
