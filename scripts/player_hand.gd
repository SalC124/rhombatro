extends Node2D

const CARD_STATES = preload("res://scripts/card_states.gd")

var player_hand: Array = []
var center_screen_x

var selected_cards: Array = []
var rhombuses: int = 0

signal selection_changed(index: int, selected: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	$"../CardManager".connect("select", on_select)

func on_select(card):
	toggle_card_select(card)


func toggle_card_select(card):
	if card.y_offset == 0:
		if selected_cards.size() < CARD_STATES.MAX_PLAYED_HAND_SIZE:
			selected_cards.append(card)
			card.y_offset = CARD_STATES.SELECTION_Y_OFFSET
			if card.suit == CARD_STATES.SUIT.Diamond:
				rhombuses += 1
			emit_signal("selection_changed", player_hand.find(card), true) # new signal bc im not making another array to keep track of changes
	else:
		selected_cards.erase(card)
		card.y_offset = 0
		if card.suit == CARD_STATES.SUIT.Diamond:
			rhombuses -= 1
		emit_signal("selection_changed", player_hand.find(card), false)




func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0,card)
		update_hand_positions(speed, player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)
	else:
		var tween = animate_card_to_position(card, card.starting_position, CARD_STATES.CARD_DRAW_SPEED)
		tween.finished.connect(func():
			update_hand_positions(speed, player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)
			for caehrd in player_hand:
				$"../CardManager".highlight_card(caehrd, false)
) # needs to use the new indexing z_index instead


func update_hand_positions(speed, hand_in_question, max_spread_width, ideal_card_distance, hand_y_position):
	for i in range(hand_in_question.size()):
		var new_z = CARD_STATES.BASE_CARD_Z_INDEX + (2*i) # 2 layers per card (face + outline)
		hand_in_question[i].z_index = new_z
		hand_in_question[i].zed_index = new_z

	var last_tween
	for i in range(hand_in_question.size()):
		var new_position = Vector2(calculate_card_position(i, hand_in_question, max_spread_width, ideal_card_distance), hand_y_position - hand_in_question[i].y_offset)
		var card = hand_in_question[i]
		card.starting_position = new_position
		last_tween = animate_card_to_position(card, new_position, speed)

	return last_tween

func calculate_card_position(index, hand_in_question, max_spread, ideal_card_distance):
	if hand_in_question.size() == 1:
		return center_screen_x

	var ideal_total_width = (hand_in_question.size() - 1) * ideal_card_distance

	var actual_total_width = min(ideal_total_width, max_spread)

	var card_spacing = actual_total_width / (hand_in_question.size() - 1)

	var x_offset = center_screen_x - (actual_total_width / 2) + (index * card_spacing)
	return x_offset

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	tween.finished.connect(func():
		card.get_node("Area2D/CollisionShape2D").disabled = false
	)
	return tween # 'tween.finished.... in add_card... relies on this

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		selected_cards.erase(card)
		update_hand_positions(CARD_STATES.CARD_DRAW_SPEED, player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)


func get_cards_in_hand() -> Array:
	return player_hand

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# debug_card_indeces()
	pass


func debug_card_indeces():
	var cards = get_cards_in_hand()
	var fmted_string = ""
	for card in cards:
		fmted_string += "c:" + str(cards.find(card)) + ",zi:" + str(card.z_index) + " "

	print(fmted_string)
