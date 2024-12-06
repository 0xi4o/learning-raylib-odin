package player

import "../config"
import "core:fmt"
import rl "vendor:raylib"

PlayerData :: struct {
	CurrentFrame: i32,
	DestRect:     rl.Rectangle,
	Flip:         bool,
	FrameTimer:   f32,
	IsGrounded:   bool,
	Origin:       rl.Vector2,
	Position:     rl.Vector2,
	Speed:        i32,
	SrcRect:      rl.Rectangle,
	Velocity:     rl.Vector2,
}

PlayerState :: enum {
	IDLE,
	RUNNING,
	JUMPING,
}

Player :: struct {
	Actions: Actions,
	Camera:  rl.Camera2D,
	Data:    PlayerData,
	State:   bit_set[PlayerState],
}

init :: proc(game_config: ^config.GameConfig) -> Player {
	// load textures before setting up player data
	player_actions := load_actions()

	// set up player data
	position := rl.Vector2{f32(game_config.WindowWidth / 2), f32(game_config.WindowHeight / 2)}
	player_camera := rl.Camera2D {
		offset   = position,
		rotation = 0.0,
		target   = position,
		zoom     = 1.0,
	}
	player_data := PlayerData {
		CurrentFrame = 0,
		IsGrounded   = true,
		Position     = position,
		Speed        = 400,
	}
	player := Player {
		Actions = player_actions,
		Camera  = player_camera,
		Data    = player_data,
		State   = {.IDLE},
	}
	return player
}

draw_debug_rectangle :: proc(
	destination_rect: rl.Rectangle,
	flip: bool,
	source_rect: rl.Rectangle,
) {
	when config.DEBUG_MODE {
		rl.DrawRectangleLines(
			i32(
				flip ? destination_rect.x + source_rect.width : destination_rect.x - source_rect.width,
			),
			i32(destination_rect.y - source_rect.height),
			i32(destination_rect.width),
			i32(destination_rect.height),
			rl.RED,
		)
	}
}

get_destination_rect :: proc(action: Action, position: rl.Vector2) -> rl.Rectangle {
	destination_rect := rl.Rectangle {
		x      = position.x,
		y      = position.y,
		width  = f32(action.FrameWidth * 2),
		height = f32(action.FrameHeight * 2),
	}
	return destination_rect
}

get_origin :: proc(action: Action) -> rl.Vector2 {
	origin := rl.Vector2{f32(action.FrameWidth), f32(action.FrameHeight)}
	return origin
}

get_source_rect :: proc(action: Action, current_frame: i32, flip: bool) -> rl.Rectangle {
	source_rect := rl.Rectangle {
		x      = f32(current_frame) * f32(action.FrameWidth),
		y      = 0,
		width  = f32(action.FrameWidth),
		height = f32(action.FrameHeight),
	}
	if flip {
		source_rect.width = -source_rect.width
	}
	return source_rect
}

update_player_frame_data :: proc(action: Action, player: ^Player) {
	player.Data.FrameTimer += rl.GetFrameTime()
	if player.Data.FrameTimer > action.FrameLength {
		player.Data.CurrentFrame += 1
		player.Data.FrameTimer = 0

		if player.Data.CurrentFrame == action.NumOfFrames {
			player.Data.CurrentFrame = 0
		}
	}
}

render_player :: proc(game_config: config.GameConfig, player: ^Player) {
	handle_key_down(game_config, player)
	if .IDLE in player.State {
		update_player_frame_data(player.Actions.Idle, player)
		render_player_idle(player)
	} else {
		if .RUNNING in player.State {
			update_player_frame_data(player.Actions.Run, player)
			render_player_running(player)
		}
		if .JUMPING in player.State {
			update_player_frame_data(player.Actions.Run, player)
			render_player_jumping(player)
		}
	}
}

render_player_idle :: proc(player: ^Player) {
	destination_rect := get_destination_rect(player.Actions.Idle, player.Data.Position)
	source_rect := get_source_rect(player.Actions.Idle, player.Data.CurrentFrame, player.Data.Flip)
	draw_debug_rectangle(destination_rect, player.Data.Flip, source_rect)
	rl.DrawTexturePro(
		player.Actions.Idle.Texture,
		source_rect,
		destination_rect,
		get_origin(player.Actions.Idle),
		0.0,
		rl.WHITE,
	)
}

render_player_running :: proc(player: ^Player) {
	destination_rect := get_destination_rect(player.Actions.Run, player.Data.Position)
	source_rect := get_source_rect(player.Actions.Run, player.Data.CurrentFrame, player.Data.Flip)
	draw_debug_rectangle(destination_rect, player.Data.Flip, source_rect)
	rl.DrawTexturePro(
		player.Actions.Run.Texture,
		source_rect,
		destination_rect,
		get_origin(player.Actions.Run),
		0.0,
		rl.WHITE,
	)
}

render_player_jumping :: proc(player: ^Player) {
	destination_rect := get_destination_rect(player.Actions.Jump, player.Data.Position)
	source_rect := get_source_rect(player.Actions.Jump, player.Data.CurrentFrame, player.Data.Flip)
	draw_debug_rectangle(destination_rect, player.Data.Flip, source_rect)
	rl.DrawTexturePro(
		player.Actions.Jump.Texture,
		source_rect,
		destination_rect,
		get_origin(player.Actions.Jump),
		0.0,
		rl.WHITE,
	)
}
