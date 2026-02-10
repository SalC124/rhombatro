extends Node2D

const CARD_STATES = preload("res://scripts/card_states.gd")

const CARD_WIDTH = 100

var player_hand: Array = []
var center_screen_x

var selected_cards: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	$"../CardManager".connect("select", on_select)

func on_select(card):
	print("on select")
	toggle_card_select(card)


func toggle_card_select(card):
	if card.y_offset == 0:
		if selected_cards.size() < CARD_STATES.MAX_PLAYED_HAND_SIZE:
			selected_cards.append(card)
			card.y_offset = CARD_STATES.SELECTION_Y_OFFSET
	else:
		selected_cards.erase(card)
		card.y_offset = 0
	print(selected_cards)


func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0,card)
		update_hand_positions(speed)
	else:
		var tween = animate_card_to_position(card, card.starting_position, CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		tween.finished.connect(func():
			update_hand_positions(speed)
			for caehrd in player_hand:
				$"../CardManager".highlight_card(caehrd, false)
) # needs to use the new indexing z_index instead


func update_hand_positions(speed):
	for i in range(player_hand.size()):
		var new_z = CARD_STATES.BASE_CARD_Z_INDEX + (2*i) # 2 layers per card (face + outline)
		player_hand[i].z_index = new_z
		player_hand[i].zed_index = new_z

	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), CARD_STATES.HAND_Y_POSITION - player_hand[i].y_offset)
		var card = player_hand[i]
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
		update_hand_positions(CARD_STATES.CARD_DRAW_SPEED)


func get_cards_in_hand() -> Array:
	return player_hand

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	debug_card_indeces()


func debug_card_indeces():
	var cards = get_cards_in_hand()
	var fmted_string = ""
	for card in cards:
		fmted_string += "c:" + str(cards.find(card)) + ",zi:" + str(card.z_index) + " "

	print(fmted_string)
