// second shader draws the character's silhouette if behind a wall

shader_type spatial;
render_mode unshaded, blend_mul, depth_test_inverted, depth_draw_never;
stencil_mode read, write, compare_not_equal, 1;

uniform vec3 shadow_colour:source_color = vec3(0.7,0.7,0.9);

void fragment() {
	ALBEDO = shadow_colour;
}