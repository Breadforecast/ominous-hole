shader_type canvas_item;


uniform sampler2D screen_tex: hint_screen_texture;


void fragment() {
	vec4 tex = texture(screen_tex, SCREEN_UV);
	vec3 col = vec3(1.0) - tex.rgb;
	COLOR.rgb = col;
}