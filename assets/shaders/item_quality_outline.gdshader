shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.33, 0.79, 0.44, 1.0);
uniform float source_pixels_per_screen_pixel = 3.6;
uniform float middle_alpha = 0.55;
uniform float outer_alpha = 0.25;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 pixel_step = TEXTURE_PIXEL_SIZE * source_pixels_per_screen_pixel;
	float near_alpha = 0.0;
	float middle_sample = 0.0;
	float outer_sample = 0.0;

	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			if (x == 0 && y == 0) {
				continue;
			}
			vec2 direction = vec2(float(x), float(y));
			near_alpha = max(near_alpha, texture(TEXTURE, UV + direction * pixel_step).a);
			middle_sample = max(middle_sample, texture(TEXTURE, UV + direction * pixel_step * 2.0).a);
			outer_sample = max(outer_sample, texture(TEXTURE, UV + direction * pixel_step * 3.0).a);
		}
	}

	float transparent_area = 1.0 - base.a;
	float inner_ring = step(0.05, near_alpha) * transparent_area;
	float middle_ring = step(0.05, middle_sample) * transparent_area * (1.0 - inner_ring);
	float outer_ring = step(0.05, outer_sample) * transparent_area * (1.0 - inner_ring) * (1.0 - middle_ring);
	float glow_alpha = inner_ring + middle_ring * middle_alpha + outer_ring * outer_alpha;
	float outline_alpha = outline_color.a * glow_alpha;
	vec3 final_rgb = mix(outline_color.rgb, base.rgb, base.a);
	COLOR = vec4(final_rgb, max(base.a, outline_alpha));
}
