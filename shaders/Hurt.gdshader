shader_type canvas_item;

uniform int flash = 2; // 1 - flash white, 2 - flash red

// config
const vec3 white = vec3(1.0, 1.0, 1.0);
const vec3 red = vec3(0.8, 0.2, 0.2);

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	if (bool(flash)) {
		vec3 to_mix = flash == 1 ? white : red;
		vec3 whitened_texture_rgb = mix(texture_color.rgb, to_mix, 0.5);
		COLOR = vec4(whitened_texture_rgb, texture_color.a);
	} else {
		COLOR = texture_color;
	}
}