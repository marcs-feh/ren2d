package render2d

import "core:math/linalg/glsl"
import "core:slice"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

vec2 :: glsl.vec2
vec3 :: glsl.vec3
vec4 :: glsl.vec4

Vertex :: struct #packed {
	position: vec2,
	color: vec4,
}

Renderer :: struct {
	screen: struct {
		width, height: i32,
	},
	default_shader: u32,
	vao: u32,
	vbo: u32,
}

renderer_create :: proc() -> Renderer {
	ren : Renderer

	vbo : u32
	gl.GenBuffers(1, &vbo)

	vao : u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	#assert(offset_of(Vertex, color) == size_of(vec2))

	// Position
	gl.VertexAttribPointer(0, len(Vertex{}.position), gl.FLOAT, false, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)

	// Color
	gl.VertexAttribPointer(1, len(Vertex{}.color), gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, color))
	gl.EnableVertexAttribArray(1)

	gl.BufferData(gl.ARRAY_BUFFER, slice.size(vertices), raw_data(vertices), gl.DYNAMIC_DRAW)

	vert_source :: #load("default.vert", string)
	frag_source :: #load("default.frag", string)

	prog, ok := gl.load_shaders_source(vert_source, frag_source)
	gl.UseProgram(prog)

	ren.vbo = vbo
	ren.vao = vao
	ren.default_shader = prog

	return ren
}

renderer_update_screen_size :: proc "contextless" (ren: ^Renderer, width, height: i32){
	viewport_uniform := gl.GetUniformLocation(ren.default_shader, "u_viewport_factors")
	gl.UseProgram(ren.default_shader)
	defer gl.UseProgram(0)

	w := f32(width / 2)
	h := f32(height / 2)
	gl.Uniform2f(viewport_uniform, 1.0 / w, 1.0 / h)
}

vertices := []Vertex {
	{
		position = {0, 0},
		color = {0.1, 1.0, 0.1, 1},
	},
	{
		position = {400, 400},
		color = {1.0, 0.1, 0.1, 1},
	},
	{
		position = {200, 400},
		color = {0.1, 0.1, 1.0, 1},
	},

	// {
	// 	position = vec3{0, 0.5, 1.0},
	// 	color = {1.0, 0, 0, 0.5},
	// },
	// {
	// 	position = vec3{-0.5, -0.5, 1.0},
	// 	color = {1.0, 0, 0, 0.5},
	// },
	// {
	// 	position = vec3{0.7, -0.5, 1.0},
	// 	color = {1.0, 0, 0, 0.5},
	// },
}

R : Renderer

main :: proc(){
	init_graphics()
	defer deinit_graphics()

	R = renderer_create()

	for !glfw.WindowShouldClose(platform.window){
		glfw.PollEvents()
		gl.ClearColor(0.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		update_vertex_data: {
			gl.BindBuffer(gl.ARRAY_BUFFER, R.vbo)
			defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
			mx, my := glfw.GetCursorPos(platform.window)
			vertices[0].position = {f32(mx), f32(my)}
			gl.BufferData(gl.ARRAY_BUFFER, slice.size(vertices), raw_data(vertices), gl.DYNAMIC_DRAW)
		}

		gl.UseProgram(R.default_shader)
		gl.BindVertexArray(R.vao)

		for &v in vertices {
			v.position.xy += 0.001
		}
		gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices) * 3))

		glfw.SwapBuffers(platform.window)
	}
	
}

