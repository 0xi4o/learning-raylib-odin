package player

import "../config"
import "core:fmt"
import rl "vendor:raylib"

PLAYER_FRAME_WIDTH :: 32
PLAYER_FRAME_HEIGHT :: 64

PlayerData :: struct {
	CurrentFrame: u8,
	DestRect:     rl.Rectangle,
	FrameLength:  f32,
	FrameTimer:   f32,
	IsGrounded:   bool,
	NumOfFrames:  u8,
	Origin:       rl.Vector2,
	Position:     rl.Vector2,
	Speed:        u16,
	SrcRect:      rl.Rectangle,
	Velocity:     rl.Vector2,
}

PlayerState :: enum {
	Idle,
	Running,
	Jumping,
	Attacking1,
	Attacking2,
}

Player :: struct {
	Camera:   rl.Camera2D,
	Data:     PlayerData,
	State:    bit_set[PlayerState],
	Textures: Textures,
}

init :: proc(game_config: ^config.GameConfig) -> Player {
	// load textures before setting up player data
	player_textures := load_textures()

	// set up player data
	frame_width := f32(PLAYER_FRAME_WIDTH)
	frame_height := f32(PLAYER_FRAME_HEIGHT)
	position := rl.Vector2{f32(game_config.WindowWidth / 2), f32(game_config.WindowHeight / 2)}
	dest_rect := rl.Rectangle {
		x      = position.x,
		y      = position.y,
		width  = frame_width * 2,
		height = frame_height * 2,
	}
	origin := rl.Vector2{frame_width, frame_height}
	src_rect := rl.Rectangle {
		x      = 0.0,
		y      = 0.0,
		width  = frame_width,
		height = frame_height,
	}
	player_camera := rl.Camera2D {
		offset   = position,
		rotation = 0.0,
		target   = position,
		zoom     = 1.0,
	}
	player_data := PlayerData {
		CurrentFrame = 0,
		DestRect     = dest_rect,
		FrameLength  = 0.1,
		IsGrounded   = true,
		Origin       = origin,
		Position     = position,
		Speed        = 400,
		SrcRect      = src_rect,
	}
	player := Player {
		Camera   = player_camera,
		Data     = player_data,
		State    = {.Idle},
		Textures = player_textures,
	}
	return player
}

update_player_frame_data :: proc(player: ^Player) {
	player.Data.FrameTimer += rl.GetFrameTime()
	if player.Data.FrameTimer > player.Data.FrameLength {
		player.Data.CurrentFrame += 1
		player.Data.FrameTimer = 0

		if player.Data.CurrentFrame == player.Data.NumOfFrames {
			player.Data.CurrentFrame = 0
		}
	}
}

update_player_rect :: proc(player: ^Player) {
	player.Data.SrcRect.x = f32(player.Data.CurrentFrame) * f32(player.Data.SrcRect.width)
	player.Data.DestRect.x = player.Data.Position.x
	player.Data.DestRect.y = player.Data.Position.y
}

render_player :: proc(game_config: config.GameConfig, player: ^Player) {
	handle_key_down(game_config, player)
	if config.DEBUG_MODE {
		rl.DrawRectangleLines(
			i32(player.Data.DestRect.x - player.Data.SrcRect.width),
			i32(player.Data.DestRect.y - player.Data.SrcRect.height),
			i32(player.Data.DestRect.width),
			i32(player.Data.DestRect.height),
			rl.RED,
		)
	}
	if .Idle in player.State {
		player.Data.NumOfFrames = 6
		update_player_frame_data(player)
		update_player_rect(player)
		render_player_idle(player)
	} else {
		if .Running in player.State {
			player.Data.NumOfFrames = 4
			update_player_frame_data(player)
			update_player_rect(player)
			render_player_running(player)
		}
		if .Jumping in player.State {
			player.Data.NumOfFrames = 4
			update_player_frame_data(player)
			update_player_rect(player)
			render_player_jumping(player)
		}
	}
}

render_player_idle :: proc(player: ^Player) {
	rl.DrawTexturePro(
		player.Textures.Idle,
		player.Data.SrcRect,
		player.Data.DestRect,
		player.Data.Origin,
		0.0,
		rl.WHITE,
	)
}

render_player_running :: proc(player: ^Player) {
	rl.DrawTexturePro(
		player.Textures.Run,
		player.Data.SrcRect,
		player.Data.DestRect,
		player.Data.Origin,
		0.0,
		rl.WHITE,
	)
}

render_player_jumping :: proc(player: ^Player) {
	rl.DrawTexturePro(
		player.Textures.Jump,
		player.Data.SrcRect,
		player.Data.DestRect,
		player.Data.Origin,
		0.0,
		rl.WHITE,
	)
}
