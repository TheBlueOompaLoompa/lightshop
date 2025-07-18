shader_type spatial;

uniform lowp uvec4 render_buf[600];

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
    ALBEDO = vec3(render_buf[int(floor((1.0-UV.x)*600.0))].rgb) / 255.0;
    EMISSION = ALBEDO * 20.0;
}
