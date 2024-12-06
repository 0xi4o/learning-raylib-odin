package game

import "config"
import "player"
import rl "vendor:raylib"

GameScreen :: enum {
	// Logo,
	Title,
	Gameplay,
	Paused,
	Exit,
}

GameData :: struct {
	CurrentScreen: GameScreen,
}

Game :: struct {
	Config: config.GameConfig,
	Data:   GameData,
	Player: player.Player,
}

init :: proc() {
	game_config := config.get_game_config()

	game_data := GameData {
		CurrentScreen = .Title,
	}

	rl.InitWindow(
		i32(game_config.WindowWidth),
		i32(game_config.WindowHeight),
		game_config.WindowTitle,
	)
	defer rl.CloseWindow()

	hero := player.init(&game_config)
	defer player.unload_textures(&hero)

	game := Game {
		Config = game_config,
		Data   = game_data,
		Player = hero,
	}

	start(&game)
}

start :: proc(game: ^Game) {
	rl.SetConfigFlags({rl.ConfigFlag.VSYNC_HINT})
	rl.SetTargetFPS(240)
	rl.SetExitKey(rl.KeyboardKey.KEY_NULL)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()

		// clear background
		rl.ClearBackground(rl.RAYWHITE)

		// if SHOW_FPS flag is set the draw FPS on screen
		if config.SHOW_FPS {
			rl.DrawFPS(10, 10)
		}

		#partial switch game.Data.CurrentScreen {
		case .Title:
			title: cstring = "My Super Awesome Game"
			text: cstring = "Press Any Key"
			title_pos := get_centered_text_pos(
				title,
				game.Config.DefaultFontSize + 20,
				game.Config.DefaultFontSpacing,
				game.Config,
			)
			text_pos := get_centered_text_pos(
				text,
				game.Config.DefaultFontSize,
				game.Config.DefaultFontSpacing,
				game.Config,
			)
			rl.DrawText(
				title,
				i32(title_pos.x),
				i32(title_pos.y),
				i32(game.Config.DefaultFontSize + 20),
				rl.LIGHTGRAY,
			)
			rl.DrawText(
				text,
				i32(text_pos.x),
				i32(text_pos.y + 40),
				i32(game.Config.DefaultFontSize),
				rl.LIGHTGRAY,
			)
			// game.Gamepad()
			pressedKey := rl.GetKeyPressed()
			if pressedKey != rl.KeyboardKey.KEY_NULL {
				game.Data.CurrentScreen = .Gameplay
			}
		case .Gameplay:
			when config.DEBUG_MODE {
				rl.DrawLine(
					i32(game.Config.WindowWidth / 2),
					0,
					i32(game.Config.WindowWidth / 2),
					i32(game.Config.WindowHeight),
					rl.RED,
				)
				rl.DrawLine(
					0,
					i32(game.Config.WindowHeight / 2),
					i32(game.Config.WindowWidth),
					i32(game.Config.WindowHeight / 2),
					rl.RED,
				)
			}
			pressedKey := rl.GetKeyPressed()
			if pressedKey == rl.KeyboardKey.ESCAPE {
				game.Data.CurrentScreen = .Paused
			} else {
				player.render_player(game.Config, &game.Player)
			}
		case .Paused:
			text: cstring = "Game Paused"
			pos := get_centered_text_pos(
				text,
				game.Config.DefaultFontSize,
				game.Config.DefaultFontSpacing,
				game.Config,
			)
			rl.DrawText(
				text,
				i32(pos.x),
				i32(pos.y) - i32(0.25 * f32(game.Config.WindowHeight)),
				i32(game.Config.DefaultFontSize + 20),
				rl.LIGHTGRAY,
			)
			pressedKey := rl.GetKeyPressed()
			if pressedKey == rl.KeyboardKey.ESCAPE {
				game.Data.CurrentScreen = .Gameplay
			}
		}

		rl.EndDrawing()
	}
}
