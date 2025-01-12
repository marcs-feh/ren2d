package render2d

import "core:math/linalg/glsl"
import "core:slice"
import "core:fmt"
import "core:math"
import "core:time"
import array "core:container/small_array"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"


Vertex :: struct #packed {
	position: vec2,
	color: vec4,
}

TEXTURE_SLOT_COUNT :: 8

Renderer :: struct {
	screen: struct {
		width, height: i32,
	},

	vertices: [dynamic]Vertex,
	indices: [dynamic]u32,
	textures: [dynamic]u32,

	texture_slots: array.Small_Array(TEXTURE_SLOT_COUNT, u32),

	vao: VAO,
	vbo: VBO,
	ebo: EBO,
	default_shader: u32,
}

renderer_create :: proc() -> Renderer {
	ren : Renderer
	ren.indices = make([dynamic]u32, 0, 256)
	ren.vertices = make([dynamic]Vertex, 0, 256)
	
	vao := gl_gen_vao()
	vbo := gl_gen_vbo()
	ebo := gl_gen_ebo()

	gl_bind_vertex_array(vao)
	defer gl_bind_vertex_array(0)

	gl_bind_vertex_buffer(vbo)
	gl_bind_element_buffer(ebo)

	#assert(offset_of(Vertex, color) == size_of(vec2))

	// Position
	gl.VertexAttribPointer(0, len(Vertex{}.position), gl.FLOAT, false, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)

	// Color
	gl.VertexAttribPointer(1, len(Vertex{}.color), gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, color))
	gl.EnableVertexAttribArray(1)

	gl_buffer_data(gl.ARRAY_BUFFER, R.vertices[:], .Dynamic_Draw)
	gl_buffer_data(gl.ELEMENT_ARRAY_BUFFER, R.indices[:], .Dynamic_Draw)

	gl.Enable(gl.BLEND);
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

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

R : Renderer

Rect :: struct {
	using pos: [2]int,
	w, h: int,
}

renderer_draw :: proc(ren: ^Renderer){
	gl.UseProgram(R.default_shader)
	gl_bind_vertex_array(R.vao)

	gl_buffer_data(gl.ARRAY_BUFFER, R.vertices[:], .Dynamic_Draw)
	gl_buffer_data(gl.ELEMENT_ARRAY_BUFFER, R.indices[:], .Dynamic_Draw)

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

renderer_load_texture :: proc(ren: ^Renderer, identifier: string, ){}

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

