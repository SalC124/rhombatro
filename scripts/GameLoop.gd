extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
@onready var player_hand_ref = $"../PlayerHand"
@onready var deck_ref = $"../Deck"


var player_played = false
var opponent_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../PlayHand".disabled=false


func _process(delta: float) -> void:
	if player_hand_ref.selected_cards.size()!=0:
		$"../Discard".disabled=false

	else:
		$"../Discard".disabled=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func opponent_turn():
	pass


func _on_play_hand_pressed() -> void:
	$"../PlayHand".disabled=true



func _on_discard_pressed() -> void:
	while player_hand_ref.selected_cards.size() > 0:
		for card in player_hand_ref.selected_cards:
			player_hand_ref.animate_card_to_position(card,Vector2(2500,1600),CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
			player_hand_ref.selected_cards.erase(card)
			player_hand_ref.player_hand.erase(card)
			player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
			deck_ref.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
