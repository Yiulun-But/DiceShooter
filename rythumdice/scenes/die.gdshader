shader_type spatial;
render_mode unshaded;
uniform sampler2D base_texture : filter_nearest;
uniform float white_threshold : hint_range(0.0, 1.0) = 0.8;
uniform float darken_multiplier : hint_range(0.0, 1.0) = 0.5;
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 flash_color : source_color = vec3(0.0, 1.0, 0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(base_texture, UV);
	
	float max_component = max(max(tex_color.r, tex_color.g), tex_color.b);
	
	float preserve_mask = smoothstep(white_threshold - 0.1, white_threshold, max_component);
	
	vec3 darkened_color = tex_color.rgb * mix(darken_multiplier, 1.0, preserve_mask);
	
	vec3 final_color = mix(darkened_color, flash_color, flash_intensity);
	
	ALBEDO = final_color;
	ALPHA = tex_color.a;
}