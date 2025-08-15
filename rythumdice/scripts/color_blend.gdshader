shader_type spatial;
uniform sampler2D surface_tex: source_color;

uniform vec4 color: source_color = vec4(.5, .5, .5, 1.0);
uniform float strength = 1.0;

void fragment() {
	vec4 tex_color = texture(surface_tex, UV);
	ALBEDO = color.rgb * strength + (1.0 - strength) * tex_color.rgb;
	ALPHA  = tex_color.a;
}