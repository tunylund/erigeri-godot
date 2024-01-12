shader_type canvas_item;

uniform vec4 edge_color = vec4(1.0, 0.0, 0.0, 1.0); // Default color: red
uniform float edge_thickness = 2.0;
uniform vec2 texture_size = vec2(96.0, 64.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 r_color = texture(TEXTURE, UV);
	vec4 r2_color = texture(TEXTURE, UV - vec2(edge_thickness / 100.0, 0));
	
	vec4 l_color = texture(TEXTURE, UV);
	vec4 l2_color = texture(TEXTURE, UV + vec2(edge_thickness / 100.0, 0));
	
	if (r_color.a > 0.0 && r2_color.a <= 0.0) {
		COLOR = edge_color;
		COLOR.a = l_color.a;
	}
	
	if (l_color.a > 0.0 && l2_color.a <= 0.0) {
		COLOR = mix(l_color, edge_color, 0.5);
		COLOR.a = l_color.a;
	}
}
//
//void fragment() {
	//
	//vec4 tex_color = texture(TEXTURE, UV);
	//vec2 offset = 1.0 / texture_size;
	//
	//// Detect edges using Sobel operator
	//float edge_strength = length(texture(TEXTURE, UV + offset) - texture(TEXTURE, UV - offset)) +
	                        //length(texture(TEXTURE, UV + vec2(offset.x, 0.0)) - texture(TEXTURE, UV - vec2(offset.x, 0.0)));
//
	//COLOR = mix(tex_color, edge_color, edge_strength * edge_thickness);
//}
