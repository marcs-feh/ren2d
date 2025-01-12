package render2d

import "core:math/linalg/glsl"
import "core:slice"
import "core:fmt"
import "core:math"
import "core:time"
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

	vertices: [dynamic]Vertex,
	indices: [dynamic]u32,

	vao: u32,
	vbo: u32,
	ebo: u32,
	default_shader: u32,
}

renderer_create :: proc() -> Renderer {
	ren : Renderer
	ren.indices = make([dynamic]u32, 0, 256)
	ren.vertices = make([dynamic]Vertex, 0, 256)

	vbo : u32
	gl.GenBuffers(1, &vbo)

	ebo : u32
	gl.GenBuffers(1, &ebo)

	vao : u32
	gl.GenVertexArrays(1, &vao)

	gl.BindVertexArray(vao)
	defer gl.BindVertexArray(0)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)

	#assert(offset_of(Vertex, color) == size_of(vec2))

	// Position
	gl.VertexAttribPointer(0, len(Vertex{}.position), gl.FLOAT, false, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)

	// Color
	gl.VertexAttribPointer(1, len(Vertex{}.color), gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, color))
	gl.EnableVertexAttribArray(1)

	gl.BufferData(gl.ARRAY_BUFFER, slice.size(R.vertices[:]), raw_data(R.vertices[:]), gl.DYNAMIC_DRAW)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, slice.size(R.indices[:]), raw_data(R.indices[:]), gl.DYNAMIC_DRAW)

	vert_source :: #load("default.vert", string)
	frag_source :: #load("default.frag", string)

	prog, ok := gl.load_shaders_source(vert_source, frag_source)
	gl.UseProgram(prog)

	ren.vbo = vbo
	ren.vao = vao
	ren.ebo = ebo
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

// vertices := []Vertex {
// 	{
// 		position = {0, 0},
// 		color = {0.1, 1.0, 0.1, 1},
// 	},
// 	{
// 		position = {400, 400},
// 		color = {1.0, 0.1, 0.1, 1},
// 	},
// 	{
// 		position = {200, 400},
// 		color = {0.1, 0.1, 1.0, 1},
// 	},
// }

R : Renderer

Shape :: union {}

Rect :: struct {
	using pos: [2]int,
	w, h: int,
}

renderer_draw :: proc(ren: ^Renderer){
	gl.Enable(gl.BLEND);
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
	gl.Enable(gl.ALPHA_TEST);

	gl.UseProgram(R.default_shader)
	gl.BindVertexArray(R.vao)

	gl.BufferData(gl.ARRAY_BUFFER, slice.size(R.vertices[:]), raw_data(R.vertices[:]), gl.DYNAMIC_DRAW)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, slice.size(R.indices[:]), raw_data(R.indices[:]), gl.DYNAMIC_DRAW)

	gl.DrawElements(gl.TRIANGLES, auto_cast len(R.indices), gl.UNSIGNED_INT, nil)

	clear(&ren.vertices)
	clear(&ren.indices)
}

renderer_push_rect :: proc(ren: ^Renderer, rect: Rect, color: vec4){
	pos := vec2{f32(rect.x), f32(rect.y)}
	w, h := f32(rect.w), f32(rect.h)

	append(&ren.vertices,
		Vertex {
			position = pos + {w, 0},
			color = color,
		},
		Vertex {
			position = pos,
			color = color,
		},
		Vertex {
			position = pos + {0, h},
			color = color,
		},
		Vertex {
			position = pos + {w, h},
			color = color,
		},
	)

	base := u32(len(ren.vertices)) - 4
	append(&ren.indices,
		base + 0, base + 1, base + 3,
		base + 1, base + 2, base + 3,
	)
}

main :: proc(){
	init_graphics()
	defer deinit_graphics()

	R = renderer_create()
	renderer_update_screen_size(&R, glfw.GetWindowSize(platform.window))

	TARGET_FPS :: 60
	TIME_PER_FRAME := time.Duration(math.trunc(f64(1.0 / TARGET_FPS) * f64(time.Second)))

	gl.ClearColor(0.0, 0.0, 0.0, 1.0)



	for !glfw.WindowShouldClose(platform.window){
		glfw.PollEvents()
		gl.Clear(gl.COLOR_BUFFER_BIT)

		mx, my := glfw.GetCursorPos(platform.window)
		frame_begin := time.now()

		renderer_push_rect(&R, {{150, 150}, 200, 200}, {0.7, 0.7, 0.4, 1.0})
		renderer_push_rect(&R, {{400, 400}, 200, 200}, {0.2, 0.7, 0.7, 1.0})
		renderer_push_rect(&R, {{auto_cast mx, auto_cast my}, 100, 200}, {0.2, 0.7, 0.4, 0.8})

		renderer_draw(&R)
		glfw.SetCursorPos(platform.window, mx, my)

		glfw.SwapBuffers(platform.window)
		frame_elapsed := time.since(frame_begin)

		frame_delay :=  TIME_PER_FRAME - frame_elapsed
		if frame_delay > 0 {
			time.sleep(frame_delay)
		}
		else {
			fmt.println("Skipped a frame")
			continue
		}
	}
	
}

