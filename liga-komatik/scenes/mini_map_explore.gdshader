shader_type canvas_item;

void fragment() {
	COLOR.a = 1.0-COLOR.r;
	COLOR.rgb = vec3(0,0,0);
}
