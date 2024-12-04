package player

import rl "vendor:raylib"

Textures :: struct {
	Attack1: rl.Texture2D,
	Attack2: rl.Texture2D,
	Idle:    rl.Texture2D,
	Jump:    rl.Texture2D,
	Run:     rl.Texture2D,
}

load_textures :: proc() -> Textures {
	textures := Textures {
		Attack1 = rl.LoadTexture("assets/player/attack1.png"),
		Attack2 = rl.LoadTexture("assets/player/attack2.png"),
		Idle    = rl.LoadTexture("assets/player/idle.png"),
		Jump    = rl.LoadTexture("assets/player/jump.png"),
		Run     = rl.LoadTexture("assets/player/run.png"),
	}
	return textures
}

unload_textures :: proc(player: ^Player) {
	rl.UnloadTexture(player.Textures.Attack1)
	rl.UnloadTexture(player.Textures.Attack2)
	rl.UnloadTexture(player.Textures.Idle)
	rl.UnloadTexture(player.Textures.Jump)
	rl.UnloadTexture(player.Textures.Run)
}
