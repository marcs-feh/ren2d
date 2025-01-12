package render2d

import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Platform :: struct {
	window: glfw.WindowHandle,
}

platform : Platform

init_graphics :: proc(){
	glfw.InitHint(glfw.WAYLAND_PREFER_LIBDECOR, 0)
	glfw.InitHint(glfw.WAYLAND_DISABLE_LIBDECOR, 1)
	if !glfw.Init(){
		msg, _ := glfw.GetError()
		fmt.panicf("Failed to init GLFW: %s", msg)
	}

	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 1)

	platform.window = glfw.CreateWindow(800, 600, "---", nil, nil)
	if platform.window == nil {
		msg, _ := glfw.GetError()
		fmt.panicf("Failed to create window: %s", msg)
	}

	glfw.SetFramebufferSizeCallback(platform.window, resize_handler)
	glfw.SetKeyCallback(platform.window, key_handler)
	glfw.SetWindowUserPointer(platform.window, &R)

	glfw.MakeContextCurrent(platform.window)
	gl.load_up_to(4, 3, glfw.gl_set_proc_address)
}

deinit_graphics :: proc(){
	glfw.DestroyWindow(platform.window)
	glfw.Terminate()
}

@(private="file")
resize_handler :: proc "c" (window: glfw.WindowHandle, width, height: i32){
	gl.Viewport(0, 0, width, height)
	ren := cast(^Renderer)glfw.GetWindowUserPointer(window)
	renderer_update_screen_size(ren, width, height)
}

@(private="file")
key_handler :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32){
}

