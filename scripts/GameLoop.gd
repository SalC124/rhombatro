extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
@onready var player_hand_ref = $"../PlayerHand"
@onready var deck_ref = $"../Deck"


var player_played = false
var opponent_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func discard_work(x_value, y_value):
	$"../Discard".disabled = true
	# Store references to the cards we want to discard
	var cards_to_discard = player_hand_ref.selected_cards.duplicate()
	
		# Clear the selection tracking
	player_hand_ref.selected_cards.clear()
	player_hand_ref.rhombuses = 0
	
	# Animate each card to the discard position
	var animation_count = cards_to_discard.size()
	var animations_completed = 0
		
	for card in cards_to_discard:
		
		# Reset the card's y_offset
		card.y_offset = 0
		
			# Remove from player_hand array
		player_hand_ref.player_hand.erase(card)
		
			# Animate to discard pile
		var tween = player_hand_ref.animate_card_to_position(card, Vector2(x_value, y_value), CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		
		tween.finished.connect(func():
			animations_completed += 1
			card.discard()
			)
				# When all animations are done, update hand and draw new cards
	
	player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
	await get_tree().create_timer(CARD_STATES.DEFAULT_CARD_MOVE_SPEED).timeout
	deck_ref.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
	$"../Discard".disabled = false 

func _on_discard_pressed() -> void:
	var player_id = multiplayer.get_unique_id()
	discard_here_and_for_clients_opponent(player_id)
	rpc("discard_here_and_for_clients_opponent", player_id)
		
	
@rpc("any_peer")
func discard_here_and_for_clients_opponent(player_id):
	if multiplayer.get_unique_id() == player_id: # Disable the button to prevent double-clicks
		discard_work(CARD_STATES.DISCARD_PLAYER_X, CARD_STATES.DISCARD_PLAYER_Y)
	else:
		discard_work(CARD_STATES.DISCARD_EVIL_X, CARD_STATES.DISCARD_EVIL_Y)      
