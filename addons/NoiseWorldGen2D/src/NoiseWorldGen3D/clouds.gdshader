shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D noise_tex;
uniform float speed = 0.02;
uniform vec4 cloud_color : source_color = vec4(1.0);

void fragment() {
    // Offset the UV over time to create a "drifting" effect
    vec2 drifting_uv = UV + vec2(TIME * speed, TIME * speed * 0.5);
    
    // Pull alpha from a noise texture
    float alpha = texture(noise_tex, drifting_uv).r;
    
    ALBEDO = cloud_color.rgb;
    ALPHA = smoothstep(0.4, 0.6, alpha); // Sharpens the cloud edges
}