#+private
package render2d

import gl "vendor:OpenGL"
import "core:math/linalg/glsl"
import "core:slice"

vec2 :: glsl.vec2
vec3 :: glsl.vec3
vec4 :: glsl.vec4

VAO :: distinct u32

VBO :: distinct u32

EBO :: distinct u32

Shader_Id :: distinct u32

Texture_Id :: distinct u32

gl_gen_vbo :: proc() -> VBO {
    n: u32
    gl.GenBuffers(1, &n)
    return VBO(n)
}

gl_gen_ebo :: proc() -> EBO {
    n: u32
    gl.GenBuffers(1, &n)
    return EBO(n)
}

gl_gen_vao :: proc() -> VAO {
    n: u32
    gl.GenVertexArrays(1, &n)
    return VAO(n)
}

gl_bind_vertex_buffer :: proc(buf: VBO){
    gl.BindBuffer(gl.ARRAY_BUFFER, u32(buf))
}

gl_bind_element_buffer :: proc (buf: EBO){
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(buf))
}

gl_bind_vertex_array :: proc(buf: VAO){
    gl.BindVertexArray(u32(buf))
}

GL_Buffer_Usage :: enum u32 {
    Stream_Draw = gl.STREAM_DRAW,
    Static_Draw = gl.STATIC_DRAW,
    Dynamic_Draw = gl.DYNAMIC_DRAW,

    Stream_Read = gl.STREAM_READ,
    Static_Read = gl.STATIC_READ,
    Dynamic_Read = gl.DYNAMIC_READ,

    Stream_Copy = gl.STREAM_COPY,
    Static_Copy = gl.STATIC_COPY,
    Dynamic_Copy = gl.DYNAMIC_COPY,
}

gl_buffer_data :: proc(target: u32, data: []$T, usage: GL_Buffer_Usage){
    gl.BufferData(target, slice.size(data), raw_data(data), u32(usage))
}