shader_type canvas_item;

uniform float is_hit = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV) + vec4(vec3(is_hit), 0.);
}
