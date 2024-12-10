package player

import "../config"
import "core:fmt"
import rl "vendor:raylib"
import sdl2 "vendor:sdl2"

Movement :: struct {}

set_player_idle :: proc(player: ^Player) {
	player.State = {.IDLE}
}

set_player_active :: proc(player: ^Player, state: PlayerState) {
	player.State -= {.IDLE}
	player.State += {state}
}

handle_gamepad :: proc(game_controller: ^sdl2.GameController) {
	if sdl2.IsGameController(0) {
		// Test if we can read a button state
		a_button := sdl2.GameControllerGetButton(game_controller, .A)
		fmt.println("A button state:", a_button)
	}
}


handle_key_down :: proc(
	game_config: config.GameConfig,
	game_controller: ^sdl2.GameController,
	player: ^Player,
) {
	// handle_gamepad(game_controller)
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
	// a_pressed := sdl2.GameControllerGetButton(game_controller, .A) == 1
	a_pressed := rl.IsGamepadButtonPressed(0, rl.GamepadButton.RIGHT_FACE_DOWN)
	fmt.println(a_pressed)
	if player.Data.IsGrounded && (rl.IsKeyPressed(.SPACE) || a_pressed) {
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
