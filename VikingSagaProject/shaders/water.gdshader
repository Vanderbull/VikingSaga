shader_type canvas_item;

// Built-in replacements with meaningful names
#define iTime TIME
#define fragColor COLOR
#define iResolution (1.0/SCREEN_PIXEL_SIZE)

// Enhanced uniforms with better organization and new features
uniform vec2 displacement_center = vec2(0.5);
uniform float animation_speed : hint_range(0.0, 20.0, 0.1) = 3.0;
uniform vec3 base_color : hint_color = vec3(0.005, 0.045, 0.075);
uniform vec3 accent_color : hint_color = vec3(0.033, 0.07, 0.03);
uniform float noise_scale : hint_range(0.1, 2.0, 0.1) = 1.0;
uniform float distortion_strength : hint_range(0.0, 2.0, 0.05) = 0.85;
uniform float vignette_strength : hint_range(0.0, 1.0, 0.05) = 0.7;

// Transformation matrix with clearer naming
uniform mat3 noise_transform = mat3(
    vec3(0.65, 1.12, -1.43),  // Row 1: X influence
    vec3(-1.75, 0.65, -0.3),  // Row 2: Y influence
    vec3(0.3, 1.4, 1.22)      // Row 3: Z influence
);

// Utility functions
mat2 rotate2d(float angle) {
    float c = cos(angle), s = sin(angle);
    return mat2(vec2(c, s), vec2(-s, c));
}

float magnitude_squared(vec2 p) {
    return dot(p, p);
}

float linear_step(float min_val, float max_val, float x) {
    return clamp((x - min_val) / (max_val - min_val), 0.0, 1.0);
}

float get_saturation(vec3 c) {
    float mi = min(min(c.x, c.y), c.z);
    float ma = max(max(c.x, c.y), c.z);
    return (ma - mi) / (ma + 1e-7);
}

// Enhanced displacement function with controllable amplitude
vec2 calculate_displacement(float t) {
    return vec2(sin(t * 0.22), cos(t * 0.175)) * distortion_strength * 2.0;
}

// Improved noise mapping function
vec2 map_clouds(vec3 p, float complexity, vec2 mouse_offset) {
    vec3 p_deformed = p;
    p_deformed.xy -= calculate_displacement(p.z).xy * noise_scale;
    
    // Dynamic rotation based on position and time
    p.xy *= rotate2d(sin(p.z + iTime) * (0.1 + complexity * 0.05) + iTime * 0.09);
    float cloud_density = magnitude_squared(p_deformed.xy);
    float density = 0.0;
    
    p *= 0.61 * noise_scale;  // Scale noise pattern
    float scale = 1.0;
    float frequency = 1.0;
    float amplitude = 0.1 + complexity * 0.2;
    
    // Optimized fractal noise loop
    for(int i = 0; i < 5; i++) {
        p += sin(p.zxy * 0.75 * frequency + iTime * frequency * 0.8) * amplitude;
        density -= abs(dot(cos(p), sin(p.yzx))) * scale;
        scale *= 0.57;
        frequency *= 1.4;
        p = p * noise_transform;
    }
    
    density = abs(density + complexity * 3.0) + complexity * 0.3 - 2.5 + mouse_offset.y;
    return vec2(density + cloud_density * 0.2 + 0.25, cloud_density);
}

// Main rendering function with improved lighting
vec4 render_clouds(vec3 ray_origin, vec3 ray_dir, float time, float complexity, vec2 mouse_offset) {
    vec4 result = vec4(0.0);
    const float light_distance = 8.0;
    vec3 light_pos = vec3(calculate_displacement(time + light_distance) * 0.5, time + light_distance);
    float t = 1.5;
    float fog_integral = 0.0;
    const int max_steps = 130;
    
    for(int i = 0; i < max_steps; i++) {
        if(result.a > 0.99) break;
        
        vec3 pos = ray_origin + t * ray_dir;
        vec2 mapped = map_clouds(pos, complexity, mouse_offset);
        float density = clamp(mapped.x - 0.3, 0.0, 1.0) * 1.12;
        float density_normalized = clamp(mapped.x + 2.0, 0.0, 3.0);
        
        vec4 color = vec4(0.0);
        if(mapped.x > 0.6) {
            // Enhanced color calculation with base and accent colors
            color = vec4(
                sin(vec3(5.0, 0.4, 0.2) + mapped.y * 0.1 + sin(pos.z * 0.4) * 0.5 + 1.8) * 0.5 + 0.5,
                0.08
            );
            color *= density * density * density;
            color.rgb *= linear_step(4.0, -2.5, mapped.x) * 2.3;
            
            // Improved lighting with multiple samples
            float diffuse = clamp((density - map_clouds(pos + 0.8, complexity, mouse_offset).x) / 9.0, 0.001, 1.0);
            diffuse += clamp((density - map_clouds(pos + 0.35, complexity, mouse_offset).x) / 2.5, 0.001, 1.0);
            color.xyz *= density * (base_color + 1.5 * accent_color * diffuse);
        }
        
        // Optimized fog calculation
        float fog_current = exp(t * 0.2 - 2.2);
        color.rgba += vec4(0.06, 0.11, 0.11, 0.1) * clamp(fog_current - fog_integral, 0.0, 1.0);
        fog_integral = fog_current;
        result += color * (1.0 - result.a);
        t += clamp(0.5 - density_normalized * density_normalized * 0.05, 0.09, 0.3);
    }
    return clamp(result, 0.0, 1.0);
}

// Improved color interpolation
vec3 interpolate_color(vec3 a, vec3 b, float t) {
    vec3 result = mix(a, b, t) + vec3(1e-6, 0.0, 0.0);
    float sat_diff = abs(get_saturation(result) - mix(get_saturation(a), get_saturation(b), t));
    vec3 dir = normalize(vec3(
        2.0 * result.x - result.y - result.z,
        2.0 * result.y - result.x - result.z,
        2.0 * result.z - result.y - result.x
    ));
    float luminance = dot(vec3(1.0), result);
    float ff = dot(dir, normalize(result));
    result += 1.5 * dir * sat_diff * ff * luminance;
    return clamp(result, 0.0, 1.0);
}

void fragment() {
    float complexity = smoothstep(-0.4, 0.4, sin(iTime * 0.3));
    vec2 mouse_offset = SCREEN_UV - displacement_center;
    vec2 uv = SCREEN_UV - 0.5;
    
    float time = iTime * animation_speed;
    vec3 ray_origin = vec3(0.0, 0.0, time);
    ray_origin += vec3(sin(iTime) * 0.5, sin(iTime * 1.0) * 0.0, 0.0);
    ray_origin.xy += calculate_displacement(ray_origin.z) * distortion_strength;
    
    const float target_distance = 3.5;
    vec3 target = normalize(ray_origin - vec3(calculate_displacement(time + target_distance) * distortion_strength, time + target_distance));
    ray_origin.x -= mouse_offset.x * 2.0;
    
    vec3 right_dir = normalize(cross(target, vec3(0.0, 1.0, 0.0)));
    vec3 up_dir = normalize(cross(right_dir, target));
    right_dir = normalize(cross(up_dir, target));
    vec3 ray_dir = normalize((uv.x * right_dir + uv.y * up_dir) * 1.0 - target);
    ray_dir.xy *= rotate2d(-calculate_displacement(time + 3.5).x * 0.2 + mouse_offset.x);
    
    vec4 scene = render_clouds(ray_origin, ray_dir, time, complexity, mouse_offset);
    vec3 final_color = scene.rgb;
    
    // Enhanced post-processing
    final_color = interpolate_color(final_color.bgr, final_color.rgb, clamp(1.0 - complexity, 0.05, 1.0));
    final_color = pow(final_color, vec3(0.55, 0.65, 0.6)) * vec3(1.0, 0.97, 0.9);
    
    // Improved vignette
    float vignette = pow(16.0 * SCREEN_UV.x * SCREEN_UV.y * (1.0 - SCREEN_UV.x) * (1.0 - SCREEN_UV.y), 0.12);
    final_color *= vignette * vignette_strength + (1.0 - vignette_strength);
    
    fragColor = vec4(final_color, 1.0);
}
