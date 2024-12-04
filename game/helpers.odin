package game

import "config"
import rl "vendor:raylib"

get_centered_text_pos :: proc(
	ctext: cstring,
	font_size: u8,
	font_spacing: u8,
	game_config: config.GameConfig,
) -> rl.Vector2 {
	font := rl.GetFontDefault()
	text_size := rl.MeasureTextEx(font, ctext, f32(font_size), f32(font_spacing))
	return rl.Vector2 {
		f32(game_config.WindowWidth / 2) - f32(text_size.x / 2) - f32(font_size),
		f32(game_config.WindowHeight / 2) - f32(text_size.y / 2),
	}
}
