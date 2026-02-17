extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
@onready var player_hand_ref = $"../PlayerHand"
@onready var deck_ref = $"../Deck"


var player_played = false
var opponent_played = false
#var opponent_hand = $"../EvilHand".evil_player_hand

var player_cards_in_play = []
var opponent_cards_in_play = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../Discard".disabled=true
	$"../PlayHand".disabled=true
	$"../CardManager".connect("select", func(card):
		button_update()
		ligma(card)
	)


func _process(_delta: float) -> void:
	pass


func ligma(_card):
	print("ligma")


func button_update():
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
	player_cards_in_play = player_hand_ref.selected_cards.duplicate()

	var last_card_moved_tween
	for card in player_cards_in_play:
		card.get_node("Area2D/CollisionShape2D").disabled = true
		last_card_moved_tween = player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, player_cards_in_play, CARD_STATES.PLAYED_HAND_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.PLAYED_HAND_Y)
		# last_card_moved_tween = player_hand_ref.animate_card_to_position(card, card.get_global_position(), CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		last_card_moved_tween.finished.connect(func():
			await get_tree().create_timer(0.01).timeout
			card.get_node("Area2D/CollisionShape2D").disabled = true
		)
		player_hand_ref.player_hand.erase(card)

	player_hand_ref.selected_cards = []
	var hand_tween = player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, player_cards_in_play, CARD_STATES.PLAYED_HAND_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.PLAYED_HAND_Y)

	var tween_to_wait_for = hand_tween if hand_tween != null else last_card_moved_tween # fallback for discard

	tween_to_wait_for.finished.connect(func():
		player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, player_hand_ref.player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)
		i_used_to_have_hoop_dreams_until_i_found_out_that_there_were_other_ways_to_score()
	)

	player_hand_ref.rhombuses = 0
	button_update()


func i_used_to_have_hoop_dreams_until_i_found_out_that_there_were_other_ways_to_score():
	pass


func _on_discard_pressed() -> void:
	var cards_to_discard = player_hand_ref.selected_cards.duplicate()

	var last_discard_tween
	for card in cards_to_discard:
		last_discard_tween = player_hand_ref.animate_card_to_position(card, Vector2(3000, 720), CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		player_hand_ref.player_hand.erase(card)

	player_hand_ref.selected_cards = []
	var hand_tween = player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, player_hand_ref.player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)

	var tween_to_wait_for = hand_tween if hand_tween != null else last_discard_tween # fallback for discard

	tween_to_wait_for.finished.connect(func():
		for card in cards_to_discard:
			card.discard()
		deck_ref.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
	)

	player_hand_ref.rhombuses = 0
	button_update()
