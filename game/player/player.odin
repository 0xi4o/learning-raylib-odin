package player

import "../config"
import rl "vendor:raylib"

PlayerData :: struct {
	DestRect:   rl.Rectangle,
	FrameSpeed: u8,
	Origin:     rl.Vector2,
	Position:   rl.Vector2,
	SrcRect:    rl.Rectangle,
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
	State:    PlayerState,
	Textures: Textures,
}

init :: proc(game_config: ^config.GameConfig) -> Player {
	// load textures before setting up player data
	player_textures := load_textures()

	// set up player data
	frame_width := f32(player_textures.Idle.width / 2)
	frame_height := f32(player_textures.Idle.height / 2)
	dest_rect := rl.Rectangle {
		x      = f32(game_config.WindowWidth / 2),
		y      = f32(game_config.WindowHeight / 2),
		width  = frame_width * 2,
		height = frame_height * 2,
	}
	origin := rl.Vector2{frame_width, frame_height}
	position := rl.Vector2{f32(game_config.WindowWidth / 2), f32(game_config.WindowHeight / 2)}
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
		FrameSpeed = 15,
		Origin     = origin,
		Position   = position,
	}
	player := Player {
		Camera   = player_camera,
		Data     = player_data,
		State    = PlayerState.Idle,
		Textures = player_textures,
	}
	return player
}
