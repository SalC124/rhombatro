extends Node2D

const CARD_SCENE_PATH = "res://scenes/Card.tscn"
const CARD_STATES = preload("res://scripts/card_states.gd")

var player_deck = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.y = CARD_STATES.HAND_Y_POSITION

func draw_card(player_hand_size):
	print("draw_card called | is_local: ", get_parent().is_local_player, " | hand size: ", $"../Hand".get_cards_in_hand().size(), " | drawing: ", player_hand_size - $"../Hand".get_cards_in_hand().size())
	var opponent = not get_parent().is_local_player
	var cards_to_draw = player_hand_size - $"../Hand".get_cards_in_hand().size()

	for i in range(cards_to_draw):
		if player_deck.size() == 0:
			break

		var card_drawn = player_deck[0]
		player_deck.erase(card_drawn)

		if player_deck.size() == 0:
			$Area2D/CollisionShape2D.disabled = true
			$Sprite2D.visible = false

		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		$"../CardManager".add_child(new_card)
		new_card.setup(card_drawn[0], card_drawn[1])
		new_card.name = "Caehrd"
		if opponent:
			new_card.set_as_opponent_card()
		else:
			new_card.get_node("Area2D/CollisionShape2D").disabled = true
		$"../Hand".add_card_to_hand(new_card, CARD_STATES.CARD_DRAW_SPEED)
		if i < cards_to_draw - 1:
			await get_tree().create_timer(0.1).timeout
