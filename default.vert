#version 410 core

layout (location = 0) in vec3 a_pos;
layout (location = 1) in uint a_packed_color;

out vec4 pos;
out vec4 unpacked_color;

vec4 unpack_u32_color(uint color){
	r = (float)((color >> 24) & 0xff);
	g = (float)((color >> 16) & 0xff);
	b = (float)((color >> 8 ) & 0xff);
	a = (float)((color      ) & 0xff);
	return vec4(r, g, b, a) / 255.0;
}

void main(){
	gl_Position = vec4(pos, 1.0);
	pos = vec4(pos, 1.0);
	unpacked_color = unpack_u32_color(a_packed_color);
}

