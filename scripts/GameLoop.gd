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



func _on_discard_pressed() -> void:
	print("=== DISCARD PRESSED ===")
	print("Selected cards: ", player_hand_ref.selected_cards.size())
	print("Cards in hand: ", player_hand_ref.player_hand.size())
	
	# Disable the button to prevent double-clicks
	$"../Discard".disabled = true
	
	# Store references to the cards we want to discard
	var cards_to_discard = player_hand_ref.selected_cards.duplicate()
	print("Cards to discard: ", cards_to_discard.size())
	
	# Clear the selection tracking
	player_hand_ref.selected_cards.clear()
	player_hand_ref.rhombuses = 0
	
	# Animate each card to the discard position
	var animation_count = cards_to_discard.size()
	var animations_completed = 0
	
	for card in cards_to_discard:
		print("Animating card: ", card.rank, " of suit ", card.suit)
		
		# Reset the card's y_offset
		card.y_offset = 0
		
		# Remove from player_hand array
		player_hand_ref.player_hand.erase(card)
		
		# Animate to discard pile
		var tween = player_hand_ref.animate_card_to_position(card, Vector2(2500, 1600), CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		
		tween.finished.connect(func():
			print("Animation finished for a card")
			animations_completed += 1
			card.discard()
			
			# When all animations are done, update hand and draw new cards
			if animations_completed == animation_count:
				print("All animations complete, updating hand")
				player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
				await get_tree().create_timer(CARD_STATES.DEFAULT_CARD_MOVE_SPEED).timeout
				deck_ref.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
				$"../Discard".disabled = false)                
