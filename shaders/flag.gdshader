shader_type canvas_item;

#include "inc/perlin1d.gdshaderinc"

uniform sampler2D atlas: filter_nearest;
uniform vec4 region = vec4(0,0,0,0);
uniform int left_static_pixels = 0;
uniform int right_static_pixels = 0;
uniform float time_scale = 1.0;
uniform float wave_scale = 0.1;


vec2 UVtoRegionUV(vec2 uv) {
	vec2 atlas_size = vec2(textureSize(atlas, 0));
	vec2 region_uvs = region.xy / atlas_size;
	vec2 region_uve = (region.xy + region.zw) / atlas_size;
	
	return mix(region_uvs, region_uve, uv);
}

void fragment() {
	float luv = float(left_static_pixels) / region.z;
	float ruv = 1.0 - (float(right_static_pixels) / region.w);
	
	
	vec4 color = texture(atlas, UVtoRegionUV(UV));
	if (UV.x > luv && UV.x < ruv){
		float offset = sin(perlin1d(UV.x + TIME * time_scale)) * wave_scale;
		vec2 uv = vec2(UV.x, clamp(UV.y + offset, 0.0, 1.0));
		color = texture(atlas, UVtoRegionUV(uv));
	//	COLOR = texture(TEXTURE, vec2(UV.x, sin(TIME)));
	}
	COLOR = color;
}
