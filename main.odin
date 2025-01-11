package render2d

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

vec2 :: glsl.vec2
vec3 :: glsl.vec3
vec4 :: glsl.vec4

Vertex :: struct #packed {
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

	vbo : u32
	gl.GenBuffers(1, &vbo)

	vao : u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	#assert(size_of(Vertex) == size_of(vec3) + size_of(u32))
	#assert(offset_of(Vertex, color) == size_of(vec3))

	// Position
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)

	// Color (packed)
	gl.VertexAttribPointer(1, 1, gl.UNSIGNED_INT, false, size_of(Vertex), offset_of(Vertex, color))
	gl.EnableVertexAttribArray(1)

	vert_source :: #load("default.vert", string)
	frag_source :: #load("default.frag", string)

	prog, ok := gl.load_shaders_source(vert_source, frag_source)
	gl.UseProgram(prog)

	for !glfw.WindowShouldClose(platform.window){
		glfw.PollEvents()
		gl.ClearColor(0.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		glfw.SwapBuffers(platform.window)
	}
}

