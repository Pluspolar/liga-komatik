shader_type canvas_item;
uniform sampler2D noise_texture : source_color, repeat_enable;
uniform vec2 center_pos = vec2(0.5, -0.25);
//uniform float mix_value : hint_range(0.0, 1.0) =  0.4;
uniform float distance_val : hint_range (0.0, 6.25) = 0.0; // 5.0 -> 0.0
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0; //1
uniform float distortion_strength : hint_range(0.0, 0.5) = 0.004; //0.005
uniform vec2 pixelation = vec2(64, 64); //0.005
uniform float speed : hint_range(0.0, 5.0) = 0.0125;

void fragment() {
	vec2 pixel_uv = floor(UV * pixelation) / pixelation;
	pixel_uv = fract(pixel_uv * noise_scale + TIME * speed);
    //vec2 noise_uv = fract(UV * noise_scale + TIME * speed);
	
    //vec4 noise_value = texture(noise_texture, noise_uv);
	vec4 pixel_noise_value = texture(noise_texture, pixel_uv);
    
    // Convert from [0,1] to [-1,1]
    vec2 offset = (pixel_noise_value.xy * 2.0 - 1.0) * distortion_strength * (distance_val*2.0+1.0);
    
	//offset = floor(offset * 256.0) / 256.0;
    vec2 distorted_uv = UV + offset;
    distorted_uv = clamp(distorted_uv, vec2(0.0), vec2(1.0));
    //distorted_uv = floor(distorted_uv * 64.0) / 64.0;
	
    COLOR = texture(TEXTURE, distorted_uv);
	COLOR.rgb *= 0.8;
	if (COLOR.a > 0.0) {
		float noise_a = mix(1.0-distance(UV, center_pos)*distance_val, pixel_noise_value.r*1.85, (distance_val)/12.5);
		noise_a = floor(noise_a * 6.0) / 6.0;
		COLOR.a = noise_a;
	}
}