package player

import "core:fmt"
import rl "vendor:raylib"

Action :: struct {
	FrameHeight: i32,
	FrameLength: f32,
	FrameWidth:  i32,
	Height:      i32,
	NumOfFrames: i32,
	Texture:     rl.Texture2D,
	Width:       i32,
}

Actions :: struct {
	Attack1: Action,
	// Attack2: Action,
	Idle:    Action,
	Jump:    Action,
	Run:     Action,
}

get_action_data :: proc(file_name: string, frame_length: f32, num_of_frames: i32) -> Action {
	texture := rl.LoadTexture(fmt.caprintf("assets/player/%s", file_name))
	action := Action {
		FrameHeight = texture.height,
		FrameLength = frame_length,
		FrameWidth  = i32(texture.width / num_of_frames),
		Height      = texture.height,
		NumOfFrames = num_of_frames,
		Texture     = texture,
		Width       = texture.width,
	}
	return action
}

load_actions :: proc() -> Actions {
	actions := Actions {
		Attack1 = get_action_data("attack1.png", 0.1, 8),
		Idle    = get_action_data("idle.png", 0.1, 6),
		Jump    = get_action_data("jump.png", 0.1, 4),
		Run     = get_action_data("run.png", 0.1, 4),
	}
	return actions
}

unload_textures :: proc(player: ^Player) {
	rl.UnloadTexture(player.Actions.Attack1.Texture)
	rl.UnloadTexture(player.Actions.Idle.Texture)
	rl.UnloadTexture(player.Actions.Jump.Texture)
	rl.UnloadTexture(player.Actions.Run.Texture)
}
