shader_type canvas_item;
uniform sampler2D noise_texture_1;
uniform sampler2D noise_texture_2;
uniform float pixel_size;
uniform float fade : hint_range(0.0, 1.0);

void fragment() {
	vec2 pixel_uv = floor(UV * pixel_size) / pixel_size;
	vec2 noise_scroll_2 = fract(pixel_uv + TIME * 0.035);
	vec2 noise_scroll_1 = fract(pixel_uv - TIME * 0.025);
	
	float noise_a_1 = texture(noise_texture_1, noise_scroll_1).r;
	float noise_a_2 = texture(noise_texture_2, noise_scroll_2).r;
	
	if (fade >= 1.0) COLOR.a = 1.0;
	else COLOR.a = fade+mix(noise_a_1*1.5, noise_a_2*2.0, fade) * (UV.x*fade);
	
	COLOR.a = floor(COLOR.a * 16.0) / 16.0;
	//else COLOR.a = fade*0.5 + mix(noise_a_1*1.5, noise_a_2*2.0, fade) * fade + (UV.x*fade);
	//COLOR.a = (sin(TIME*10.0 + UV.x * 1000.0)*0.5) + 0.5;
}
