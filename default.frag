#version 410 core

in vec4 pos;
in vec4 vert_color;

out vec4 frag_color;

void main(){
	frag_color = vert_color;
}

