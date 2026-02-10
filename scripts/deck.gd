extends Node2D

const CARD_SCENE_PATH = "res://scenes/Card.tscn"
const CARD_STATES = preload("res://scripts/card_states.gd")

var player_deck = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(2,15):
		for j in range(0,4):
			player_deck.append([i,j])
	player_deck.shuffle()
	print(player_deck)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func draw_card(player_hand_size):
	var cards_to_draw = player_hand_size - $"../PlayerHand".get_cards_in_hand().size()

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
		$"../PlayerHand".add_card_to_hand(new_card, CARD_STATES.CARD_DRAW_SPEED)

		if i < cards_to_draw - 1:  # dont wait after the last card
			await get_tree().create_timer(0.1).timeout # thanks, claude
