shader_type canvas_item;
uniform sampler2D noise;

void fragment() {
	float noise_a = texture(noise, UV).r;
	COLOR.a = noise_a;
	COLOR.rgb = vec3(0,0,0);
}
