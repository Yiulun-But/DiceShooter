shader_type canvas_item;

// Uniforms for customization
uniform float scroll_offset : hint_range(-10.0, 10.0) = 0.0;
uniform float subdivision = 4.0;
uniform float main_beat_width : hint_range(0.002, 0.02) = 0.01;
uniform float sub_beat_width : hint_range(0.001, 0.01) = 0.006;
uniform float main_beat_height : hint_range(0.1, 0.5)= 0.15;
uniform float sub_beat_height : hint_range(0.05, 0.5) = 0.25;
uniform vec4 main_beat_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 sub_beat_color : source_color = vec4(0.7, 0.7, 0.7, 0.8);
uniform vec4 background_color : source_color = vec4(0.1, 0.1, 0.2, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.5;

// Function to create a vertical line with glow effect
float create_line(vec2 uv, float x_pos, float width, float height) {
    float line_start_bottom = 1.0 - 0.5 * height;
    float line_end_bottom = 1.0;
    float line_start_up = 0.0;
    float line_end_up = 0.5 * height;
    
    // Check if we're within EITHER the top OR bottom segment
    bool in_top_segment = (uv.y >= line_start_up && uv.y <= line_end_up);
    bool in_bottom_segment = (uv.y >= line_start_bottom && uv.y <= line_end_bottom);
    
    if (!in_top_segment && !in_bottom_segment) {
        return 0.0;
    }
    
    // Calculate distance from the center of the line
    float dist = abs(uv.x - x_pos);
    
    // Main line
    float line = smoothstep(width * 0.5, width * 0.3, dist);
    
    // Glow effect
    float glow = smoothstep(width * 2.0, width * 0.5, dist) * glow_intensity * 0.3;
    
    return max(line, glow);
}

void fragment() {
    vec2 uv = UV;
	uv.x = fract(uv.x + scroll_offset);
    vec3 final_color = background_color.rgb;
    float alpha = background_color.a;
    
    // Main beat marker at the leftmost edge (center at x = 0.0)
    float main_beat_x = 0.0;
    float main_beat = create_line(uv, main_beat_x, main_beat_width, 0.4);
    
    // Blend main beat
    final_color = mix(final_color, main_beat_color.rgb, main_beat * main_beat_color.a);
    alpha = max(alpha, main_beat * main_beat_color.a);
    
    // Sub-beat markers - start after the main beat and distribute across the full texture
	float beat_spacing = 1.0 / subdivision;
    float start_x = beat_spacing;
    float end_x = 1.0; // Use full texture width
    float available_width = end_x - start_x;
    
    // Calculate number of sub-beats that fit
    int num_sub_beats = int(available_width / beat_spacing);
    
    // Draw sub-beat markers
    for (int i = 0; i < num_sub_beats; i++) {
        float sub_beat_x = start_x + float(i) * beat_spacing;
        
        // Make sure we don't go past the right edge
        if (sub_beat_x >= end_x) break;
        
        float sub_beat = create_line(uv, sub_beat_x, sub_beat_width, sub_beat_height);
        
        // Blend sub-beat
        final_color = mix(final_color, sub_beat_color.rgb, sub_beat * sub_beat_color.a);
        alpha = max(alpha, sub_beat * sub_beat_color.a);
    }
    
    COLOR = vec4(final_color, alpha);
}