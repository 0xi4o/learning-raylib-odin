package config

import rl "vendor:raylib"

DEBUG_MODE :: #config(DEBUG_MODE, false)
SHOW_FPS :: #config(SHOW_FPS, false)

GameConfig :: struct {
	DefaultFont:        rl.Font,
	DefaultFontSize:    u8,
	DefaultFontSpacing: u8,
	WindowHeight:       u16,
	WindowTitle:        cstring,
	WindowWidth:        u16,
}

get_game_config :: proc() -> GameConfig {
	game_config := GameConfig {
		DefaultFont        = rl.GetFontDefault(),
		DefaultFontSize    = 20,
		DefaultFontSpacing = 1,
		WindowHeight       = 1080,
		WindowTitle        = "learning odin & raylib",
		WindowWidth        = 1920,
	}
	return game_config
}
