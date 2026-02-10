extends Node2D

const CARD_STATES = preload("res://scripts/card_states.gd")

const CARD_WIDTH = 100
const HAND_Y_POSITION = 500
const DEFAULT_CARD_MOVE_SPEED = 0.5

var player_hand: Array = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2



func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0,card)
		update_hand_positions(speed)
	else:
		var tween = animate_card_to_position(card, card.starting_position, CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		tween.finished.connect(func(): card.z_index = 1)

func update_hand_positions(speed):
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card= player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	var total_width = (player_hand.size()-1)*CARD_STATES.CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_STATES.CARD_WIDTH - total_width / 2
	return x_offset

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	return tween # 'tween.finished.... in add_card... relies on this

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(0.067)


func get_cards_in_hand() -> Array:
	return player_hand

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
