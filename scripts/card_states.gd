extends Resource

const CARD_DRAW_SPEED: float = 0.067
const DEFAULT_CARD_MOVE_SPEED: float = 0.2

# const CARD_WIDTH: int = (1600 - (DEFAULT_HAND_SIZE * (71 * 2))) / 8
const CARD_WIDTH: int = 120

enum SUIT {
	Heart = 0,
	Club = 1,
	Diamond = 2,
	Spade = 3,
}

enum RANK {

}

const DEFAULT_HAND_SIZE: int = 8

const DRAG_SMOOTHNESS: float = 0.1  # Lower = more lag (0.1-0.3 is good range)

const BASE_CARD_Z_INDEX: int = 1
const BASE_HOVER_Z_INDEX: int = 50
const CARD_DRAG_Z_INDEX: int = 100
