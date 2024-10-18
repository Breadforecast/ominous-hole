shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float colors_per_channel : hint_range(2.0, 256.0, 1.0);
uniform float spread : hint_range(0.0, 1.0, 0.01);

const mat4 _bayer_4 = mat4(
	vec4(0.0, 8.0, 2.0, 10.0),
	vec4(12.0, 4.0, 14.0, 6.0),
	vec4(3.0, 11.0, 1.0, 9.0),
	vec4(15.0, 7.0, 13.0, 5.0)
	);
const float _bayer_size = 4.0;

void fragment() {
	/*
	Get the bayer matrix coordinate and then retrieve its value.
	Multiply it by the size of the matrix to get it into the 0-1 range.
	Subtract 0.5 to normalize it.
	*/
	int x = int(mod(FRAGCOORD.x, _bayer_size));
	int y = int(mod(FRAGCOORD.y, _bayer_size));
	float matrix_sample = _bayer_4[x][y] * (1.0 / pow(_bayer_size, 2)) - 0.5;

	// Just set the initial output as the screen.
	vec3 output = texture(screen_texture, SCREEN_UV).rgb;

	// Perform the bayer matrix stuff.
	output = output + spread * matrix_sample;

	// Quantize the colors.
	output.r = floor(output.r * (colors_per_channel - 1.0) + 0.5) / (colors_per_channel - 1.0);
	output.g = floor(output.g * (colors_per_channel - 1.0) + 0.5) / (colors_per_channel - 1.0);
	output.b = floor(output.b * (colors_per_channel - 1.0) + 0.5) / (colors_per_channel - 1.0);

	// Assign the output to the actual colors.
	COLOR.rgb = output;
}