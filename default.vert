#version 410 core

layout (location = 0) in vec2 a_pos;
layout (location = 1) in vec4 a_color;

uniform vec2 u_viewport_factors;

out vec4 pos;
out vec4 vert_color;

void main(){
	pos = vec4(
		(a_pos.x * u_viewport_factors.x) - 1.0,
		(-a_pos.y * u_viewport_factors.y) + 1.0,
		1.0,
		1.0
	);
	gl_Position = pos;
	vert_color = a_color;
}
