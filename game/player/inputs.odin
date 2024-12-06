package player

import "../config"
import rl "vendor:raylib"

set_player_idle :: proc(player: ^Player) {
	player.State = {.IDLE}
}

set_player_active :: proc(player: ^Player, state: PlayerState) {
	player.State -= {.IDLE}
	player.State += {state}
}

handle_key_down :: proc(game_config: config.GameConfig, player: ^Player) {
	is_moving: bool
	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
		set_player_active(player, .RUNNING)
		player.Data.Velocity.x = -f32(player.Data.Speed)
		player.Data.Flip = true
		is_moving = true
	} else if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
		set_player_active(player, .RUNNING)
		player.Data.Velocity.x = f32(player.Data.Speed)
		player.Data.Flip = false
		is_moving = true
	}
	player.Data.Velocity.y += 2000 * rl.GetFrameTime()
	if player.Data.IsGrounded && rl.IsKeyPressed(.SPACE) {
		set_player_active(player, .JUMPING)
		player.Data.Velocity.y = -800
		player.Data.IsGrounded = false
		is_moving = true
	}
	player.Data.Position += player.Data.Velocity * rl.GetFrameTime()
	if player.Data.Position.y > f32(game_config.WindowHeight / 2) {
		player.Data.Position.y = f32(game_config.WindowHeight / 2)
		player.Data.IsGrounded = true
		player.Data.Velocity.y = 0
		player.State -= {.JUMPING}
	}
	if !is_moving {
		player.Data.Velocity.x = 0
		if .JUMPING not_in player.State {
			set_player_idle(player)
		}
	}
}
