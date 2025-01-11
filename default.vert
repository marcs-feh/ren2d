#version 410 core

layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec4 a_color;

out vec4 pos;
out vec4 vert_color;

void main(){
	pos = vec4(a_pos, 1.0);
	gl_Position = pos;
	vert_color = a_color;
}
