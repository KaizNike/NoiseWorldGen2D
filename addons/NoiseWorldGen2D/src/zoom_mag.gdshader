shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float zoom_factor : hint_range(0.0, 25.0) = 2.0;
uniform vec2 planet_screen_pos; // Normalized (0.0 to 1.0)

void fragment() {
    // Calculate the distance from the center of this UI element
    vec2 rel_uv = UV - vec2(0.5);
    
    // Scale the UVs to create the magnification effect
    // We sample the screen texture around the planet's actual position
    vec2 zoom_uv = planet_screen_pos + (rel_uv / zoom_factor);
    
    // Circular masking so it looks like a lens
    float dist = distance(UV, vec2(0.5));
    if (dist > 0.5) {
        discard; // Or set ALPHA = 0.0 for a transparent background
    }

    COLOR = texture(screen_texture, zoom_uv);
}