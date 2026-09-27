shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.2, 0.75, 0.8, 0.85);
uniform vec4 deep_color : source_color = vec4(0.02, 0.2, 0.45, 0.95);
uniform float wave_speed = 0.5;
uniform float wave_height = 0.08;
uniform float wave_freq = 3.0;

varying vec3 world_pos;

void vertex() {
	world_pos = VERTEX;
	float t = TIME * wave_speed;
	VERTEX.y += sin(VERTEX.x * wave_freq + t) * wave_height * 0.5;
	VERTEX.y += cos(VERTEX.z * wave_freq * 0.8 + t * 1.3) * wave_height * 0.5;
}

void fragment() {
	float depth_mix = clamp(length(world_pos.xz) * 0.01, 0.0, 1.0);
	ALBEDO = mix(shallow_color.rgb, deep_color.rgb, depth_mix);
	ALPHA = mix(shallow_color.a, deep_color.a, depth_mix);
	ROUGHNESS = 0.15;
	METALLIC = 0.05;
	SPECULAR = 0.8;
}
