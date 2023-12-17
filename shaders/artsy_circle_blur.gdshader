shader_type canvas_item;

// Obtained from...
// https://godotshaders.com/shader/artsy-circle-blur-type-thingy/

uniform float v = 1.0; 
uniform float size = 10.0;
uniform sampler2D screen_tex : hint_screen_texture;

void fragment() {
	vec4 c = textureLod(screen_tex, SCREEN_UV, 0.0);
	for (float x = -size; x < size; x++)
	{
		for (float y = -size; y < size; y++)
		{
			if (x*x + y*y > size*size){continue;}
			vec4 new_c = texture(screen_tex, SCREEN_UV+SCREEN_PIXEL_SIZE*vec2(x, y));
			if (length(new_c) >length(c)){
				c = new_c;
			}
		}
	}
	COLOR = c;
	
}
