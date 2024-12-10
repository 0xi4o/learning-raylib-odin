package game

import "core:fmt"
import sdl2 "vendor:sdl2"

init_controller :: proc() -> ^sdl2.GameController {
	for i in 0 ..< sdl2.NumJoysticks() {
		if sdl2.IsGameController(i) {
			controller := sdl2.GameControllerOpen(i)
			error := sdl2.GetError()
			if error != nil {
				fmt.eprintfln("error: %s", error)
			}
			return controller
		}
	}

	return nil
}

close_controller :: proc(controller: ^sdl2.GameController) {
	sdl2.GameControllerClose(controller)
}
