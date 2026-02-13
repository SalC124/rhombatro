extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
@onready var PLAYER_HAND_REF = $"../PlayerHand"
@onready var DECK_REF = $"../Deck"


var player_played = false
var opponent_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../PlayHand".disabled=false


func _process(delta: float) -> void:
	if PLAYER_HAND_REF.selected_cards.size()!=0:
		$"../Discard".disabled=false
		
	else: 
		$"../Discard".disabled=true
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func opponent_turn():
	pass


func _on_play_hand_pressed() -> void:
	$"../PlayHand".disabled=true
	


func _on_discard_pressed() -> void:
	while PLAYER_HAND_REF.selected_cards.size() > 0:
		for card in PLAYER_HAND_REF.selected_cards:
			PLAYER_HAND_REF.animate_card_to_position(card,Vector2(2500,1600),CARD_STATES.CARD_DRAW_SPEED)
			PLAYER_HAND_REF.selected_cards.erase(card)
			PLAYER_HAND_REF.player_hand.erase(card)
			PLAYER_HAND_REF.update_hand_positions(CARD_STATES.CARD_DRAW_SPEED)
			DECK_REF.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
