package render2d

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

vec2 :: glsl.vec2
vec3 :: glsl.vec3
vec4 :: glsl.vec4

Vertex_Flat :: struct #packed {
	position: vec3,
	color: u32,
}

Renderer :: struct {
	screen: struct {
		width, height: i32,
	},

	vbo: u32,
	ebo: u32,
	vao: u32,
}

renderer_create :: proc() -> Renderer {
	ren : Renderer
	gl.GenBuffers(1, &ren.vbo)

	ebo : u32
	gl.GenBuffers(1, &ren.ebo)

	return ren
}

main :: proc(){
	init_graphics()
	defer deinit_graphics()

	for !glfw.WindowShouldClose(platform.window){
		glfw.PollEvents()
		gl.ClearColor(0.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		glfw.SwapBuffers(platform.window)
	}
}

