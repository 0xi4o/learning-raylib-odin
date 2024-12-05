package player

import "../config"
import "core:fmt"
import rl "vendor:raylib"

set_player_idle :: proc(player: ^Player) {
	player.State = {.Idle}
}

set_player_active :: proc(player: ^Player, state: PlayerState) {
	player.State -= {.Idle}
	player.State += {state}
}

handle_key_down :: proc(game_config: config.GameConfig, player: ^Player) {
	is_moving: bool
	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
		set_player_active(player, .Running)
		player.Data.Velocity.x = -f32(player.Data.Speed)
		is_moving = true
	} else if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
		set_player_active(player, .Running)
		player.Data.Velocity.x = f32(player.Data.Speed)
		is_moving = true
	}
	player.Data.Velocity.y += 2000 * rl.GetFrameTime()
	if player.Data.IsGrounded && rl.IsKeyPressed(.SPACE) {
		set_player_active(player, .Jumping)
		player.Data.Velocity.y = -600
		player.Data.IsGrounded = false
		is_moving = true
	}
	player.Data.Position += player.Data.Velocity * rl.GetFrameTime()
	if player.Data.Position.y > f32(game_config.WindowHeight / 2) {
		player.Data.Position.y = f32(game_config.WindowHeight / 2)
		player.Data.IsGrounded = true
	}
	if !is_moving {
		player.Data.Velocity.x = 0
		set_player_idle(player)
	}
}
