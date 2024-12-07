package player

import "../config"
import "core:fmt"
import rl "vendor:raylib"

Movement :: struct {}

set_player_idle :: proc(player: ^Player) {
	player.State = {.IDLE}
}

set_player_active :: proc(player: ^Player, state: PlayerState) {
	player.State -= {.IDLE}
	player.State += {state}
}

handle_input :: proc(game_config: config.GameConfig, player: ^Player) {
	// Print number of gamepads detected
	// gamepad_count := rl.GetGamepadCount()
	// fmt.println("Number of gamepads:", gamepad_count)

	gamepad: i32 = 0

	// Check if gamepad is available and print result
	is_available := rl.IsGamepadAvailable(gamepad)
	fmt.println("Gamepad available:", is_available)

	if is_available {
		// Print gamepad name and ID
		name := rl.GetGamepadName(gamepad)
		fmt.println("Gamepad name:", name)

		// Try to get the raw axis count
		axis_count := rl.GetGamepadAxisCount(gamepad)
		fmt.println("Number of axes:", axis_count)

		// Print all possible axis values
		for axis in 0 ..= axis_count - 1 {
			value := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis(axis))
			fmt.printf("Axis %d: %f\n", axis, value)
		}

		// Print button states for all possible buttons
		for button in 0 ..= 15 { 	// Most gamepads have up to 16 buttons
			is_pressed := rl.IsGamepadButtonPressed(gamepad, rl.GamepadButton(button))
			is_down := rl.IsGamepadButtonDown(gamepad, rl.GamepadButton(button))
			if is_pressed || is_down {
				fmt.printf("Button %d - Pressed: %v, Down: %v\n", button, is_pressed, is_down)
			}
		}
	}
}

// handle_input :: proc(game_config: config.GameConfig, player: ^Player) {
// 	gamepad: i32 = 0
// 	DEADZONE :: 0.2 // Adjust this value as needed
//
// 	if rl.IsGamepadAvailable(gamepad) {
// 		left_stick_x := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.LEFT_X)
// 		left_stick_y := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.LEFT_Y)
// 		if abs(left_stick_x) > DEADZONE || abs(left_stick_y) > DEADZONE {
// 			fmt.printfln("%f, %f", left_stick_x, left_stick_y)
// 		}
//
// 		right_stick_x := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.RIGHT_X)
// 		right_stick_y := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.RIGHT_Y)
// 		if abs(right_stick_x) > DEADZONE || abs(right_stick_y) > DEADZONE {
// 			fmt.printfln("%f, %f", right_stick_x, right_stick_y)
// 		}
// 	}
// if rl.IsGamepadAvailable(gamepad) {
// 	left_stick_x := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.LEFT_X)
// 	left_stick_y := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.LEFT_Y)
// 	if left_stick_x != 0 || left_stick_y != 0 {
// 		fmt.printfln("%f, %f", left_stick_x, left_stick_y)
// 	}
// 	right_stick_x := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.RIGHT_X)
// 	right_stick_y := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis.RIGHT_Y)
// 	if right_stick_x != 0 || right_stick_y != 0 {
// 		fmt.printfln("%f, %f", right_stick_x, right_stick_y)
// 	}
// 	// if rl.IsGamepadButtonPressed(0, rl.GamepadButton.RIGHT_FACE_DOWN) {
// 	// 	button_pressed := rl.GetGamepadButtonPressed()
// 	// 	fmt.printfln("%v", button_pressed)
// 	// }
// }
// if rl.IsGamepadAvailable(gamepad) {
// fmt.printf("Gamepad name: %s\n", rl.GetGamepadName(gamepad))
//
// // Print all axis values
// for axis in 0 ..= 5 { 	// Raylib typically supports 6 axes (0-5)
// 	value := rl.GetGamepadAxisMovement(gamepad, rl.GamepadAxis(axis))
// 	fmt.printf("Axis %d: %f\n", axis, value)
// }
// For single press detection (triggers once when pressed)
// if rl.IsGamepadButtonPressed(gamepad, rl.GamepadButton.RIGHT_FACE_DOWN) {
// 	fmt.println("Button pressed!")
// }

// For continuous press detection (triggers every frame while held)
// 	if rl.IsGamepadButtonDown(gamepad, rl.GamepadButton.RIGHT_FACE_DOWN) {
// 		fmt.println("Button held down!")
// 	}
// }
// }

handle_key_down :: proc(game_config: config.GameConfig, player: ^Player) {
	handle_input(game_config, player)
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
