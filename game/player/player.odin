package player

import "../config"
import "core:fmt"
import rl "vendor:raylib"

PLAYER_FRAME_WIDTH :: 32
PLAYER_FRAME_HEIGHT :: 64

PlayerData :: struct {
	DestRect:   rl.Rectangle,
	FrameSpeed: u16,
	IsGrounded: bool,
	Origin:     rl.Vector2,
	Position:   rl.Vector2,
	SrcRect:    rl.Rectangle,
	Velocity:   rl.Vector2,
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
		DestRect   = dest_rect,
		FrameSpeed = 400,
		IsGrounded = true,
		Origin     = origin,
		Position   = position,
		SrcRect    = src_rect,
	}
	player := Player {
		Camera   = player_camera,
		Data     = player_data,
		State    = {.Idle},
		Textures = player_textures,
	}
	return player
}

render_player :: proc(game_config: config.GameConfig, player: ^Player) {
	handle_key_down(game_config, player)
	player.Data.DestRect.x = player.Data.Position.x
	player.Data.DestRect.y = player.Data.Position.y
	if .Idle in player.State {
		render_player_idle(player)
	} else {
		if .Running in player.State {
			render_player_running(player)
		}
		if .Jumping in player.State {
			render_player_running(player)
		}
	}
}

render_player_idle :: proc(player: ^Player) {
	if config.DEBUG_MODE {
		rl.DrawRectangleLines(
			i32(player.Data.DestRect.x - player.Data.SrcRect.width),
			i32(player.Data.DestRect.y - player.Data.SrcRect.height),
			i32(player.Data.DestRect.width),
			i32(player.Data.DestRect.height),
			rl.RED,
		)
	}
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
	if config.DEBUG_MODE {
		rl.DrawRectangleLines(
			i32(player.Data.DestRect.x - player.Data.SrcRect.width),
			i32(player.Data.DestRect.y - player.Data.SrcRect.height),
			i32(player.Data.DestRect.width),
			i32(player.Data.DestRect.height),
			rl.RED,
		)
	}
	rl.DrawTexturePro(
		player.Textures.Run,
		player.Data.SrcRect,
		player.Data.DestRect,
		player.Data.Origin,
		0.0,
		rl.WHITE,
	)
}
