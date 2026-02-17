extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
@onready var player_hand_ref = $"../Hand"
@onready var deck_ref = $"../Deck"


var player_played = false
var opponent_played = false
var scoring_refs = []
#var opponent_hand = $"../EvilHand".evil_player_hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../PlayHand".disabled=true
	$"../CardManager".connect("select", button_update)


func _process(_delta: float) -> void:
	pass


func button_update(_card):
	if player_hand_ref.selected_cards.size() == 0:
		$"../Discard".disabled=true
		$"../PlayHand".disabled=true
	else:
		$"../Discard".disabled=false
		if player_hand_ref.rhombuses > 0:
			$"../PlayHand".disabled = false
		else:
			$"../PlayHand".disabled = true
	print(player_hand_ref.rhombuses)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func opponent_turn():
	pass


func _on_play_hand_pressed() -> void:
	$"../PlayHand".disabled=true

func set_scoring_refs(peer_id: int, node_ref: Node) -> void:
	scoring_refs[peer_id] = node_ref
	

func _on_discard_pressed() -> void:
	var selected_cards_clone = player_hand_ref.selected_cards
	while player_hand_ref.selected_cards.size() > 0:
		var card = player_hand_ref.selected_cards[player_hand_ref.selected_cards.size() - 1]
		player_hand_ref.animate_card_to_position(card, Vector2(2500, 1600), CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		player_hand_ref.selected_cards.erase(card)
		player_hand_ref.player_hand.erase(card)

	var tween = player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED)

	tween.finished.connect(func():
		while selected_cards_clone.size() > 0:
			selected_cards_clone[0].discard()
		deck_ref.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
	)
	player_hand_ref.rhombuses = 0
