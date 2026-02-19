extends Node2D

var hp = CARD_STATES.STARTING_HP
var shield = 0

var owner_peer_id: int
var is_local_player: bool

const CARD_STATES = preload("res://scripts/card_states.gd")
@onready var player_hand_ref = $"Hand"
@onready var deck_ref = $"Deck"


var player_cards_in_play = []

signal death(id: int)
signal round_ready(peer_id: int)

const HP_BAR_SCENE = preload("res://scripts/hp_bar.gd")
var hp_bar: CanvasLayer = null


func has_playable_hand() -> bool:
	for card in player_hand_ref.player_hand:
		if card.suit == CARD_STATES.SUIT.Diamond:
			return true
	for card_data in deck_ref.player_deck:
		if card_data[1] == CARD_STATES.SUIT.Diamond:
			return true
	return false


func take_damage(dmg: int) -> void:
	hp = max(0, hp - dmg)
	if hp_bar:
		hp_bar.animate_to(hp)
	if hp == 0:
		emit_signal("death", owner_peer_id)


func heal(medkits: int) -> void:
	hp = min(CARD_STATES.STARTING_HP, hp + medkits)
	if hp_bar:
		hp_bar.animate_to(hp)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _ready_setup() -> void:
	is_local_player = owner_peer_id == multiplayer.get_unique_id()

	if not is_local_player:
		rotation = PI
		position = Vector2(2560, 1440)
	else:
		hp_bar = HP_BAR_SCENE.new()
		add_child(hp_bar)


	$"CardManager".connect("select", func(_card):
		get_parent().get_node("GameLoop").button_update()
	)

	if is_local_player:
		player_hand_ref.selection_changed.connect(func(index, selected):
			rpc("receive_selection", index, selected)
		)

func discard_from_played_hand(caehrds: Array) -> void:
	var last_tween
	for caehrd in caehrds:
		last_tween = player_hand_ref.animate_card_to_position(caehrd, Vector2(3000, 720), CARD_STATES.DEFAULT_CARD_MOVE_SPEED)

	if last_tween == null:
		emit_signal("round_ready", owner_peer_id)
		return

	last_tween.finished.connect(func():
		for caehrd in caehrds:
			caehrd.discard()
		await deck_ref.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
		emit_signal("round_ready", owner_peer_id)
	)

@rpc("any_peer")
func rpc_discard_from_played_hand() -> void:
	if is_local_player:
		return
	discard_from_played_hand(opponent_cards_in_play.duplicate())


@rpc("any_peer")
func receive_selection(index: int, selected: bool) -> void:
	if is_local_player:
		return
	var card = player_hand_ref.player_hand[index]
	card.y_offset = CARD_STATES.SELECTION_Y_OFFSET if selected else 0
	player_hand_ref.update_hand_positions(CARD_STATES.CARD_DRAW_SPEED, player_hand_ref.player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_play_hand_pressed() -> void:
	if not is_local_player:
		return # return early so nothing gets impacted by the opponent
	player_cards_in_play = player_hand_ref.selected_cards.duplicate()

	var card_data = player_cards_in_play.map(func(caehrd): return [caehrd.rank, caehrd.suit])
	var indeces = player_cards_in_play.map(func(caehrd):
		return player_hand_ref.player_hand.find(caehrd)
	)
	rpc("receive_play_hand", indeces)
	var game_loop = get_parent().get_node("GameLoop")
	game_loop.submit_played_hand(owner_peer_id, card_data)
	game_loop.rpc("rpc_submit_played_hand", owner_peer_id, card_data)

	var last_card_moved_tween
	for card in player_cards_in_play:
		card.get_node("Area2D/CollisionShape2D").disabled = true
		last_card_moved_tween = player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, player_cards_in_play, CARD_STATES.PLAYED_HAND_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.PLAYED_HAND_Y)
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
	)

	player_hand_ref.rhombuses = 0
	get_parent().get_node("GameLoop").button_update()


var opponent_cards_in_play = []

@rpc("any_peer")
func receive_play_hand(indeces: Array) -> void:
	if is_local_player:
		return
	var cards_to_play = indeces.map(func(i):
		for card in player_hand_ref.player_hand:
				return player_hand_ref.player_hand[i]
	)

	opponent_cards_in_play = cards_to_play.duplicate()
	player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, cards_to_play, CARD_STATES.PLAYED_HAND_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.PLAYED_HAND_Y)
	for card in cards_to_play:
		player_hand_ref.player_hand.erase(card)
	player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, player_hand_ref.player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)


func _on_discard_pressed() -> void:
	if not is_local_player:
		return # return early so nothing gets impacted by the opponent
	var cards_to_discard = player_hand_ref.selected_cards.duplicate()

	var indeces = cards_to_discard.map(func(caehrd):
		return player_hand_ref.player_hand.find(caehrd)
	)
	rpc("receive_discard", indeces)

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
	get_parent().get_node("GameLoop").button_update()


@rpc("any_peer")
func receive_discard(indeces: Array) -> void:
	if is_local_player:
		return
	var cards_to_discard = indeces.map(func(i):
		return player_hand_ref.player_hand[i]
	)
	var last_tween
	for card in cards_to_discard:
		last_tween = player_hand_ref.animate_card_to_position(card, Vector2(3000, 720), CARD_STATES.DEFAULT_CARD_MOVE_SPEED)
		player_hand_ref.player_hand.erase(card)
	var hand_tween = player_hand_ref.update_hand_positions(CARD_STATES.DEFAULT_CARD_MOVE_SPEED, player_hand_ref.player_hand, CARD_STATES.DEFAULT_MAX_SPREAD_WIDTH, CARD_STATES.DEFAULT_IDEAL_CARD_DISTANCE, CARD_STATES.HAND_Y_POSITION)
	var tween_to_wait_for = hand_tween if hand_tween != null else last_tween
	tween_to_wait_for.finished.connect(func():
		deck_ref.draw_card(CARD_STATES.DEFAULT_HAND_SIZE)
	)


func generate_and_share_deck() -> void:
	var derkta = [] # short for 'deck data'
	for i in range(2,15):
		for j in range(0,4):
			derkta.append([i,j])
	derkta.shuffle()
	deck_ref.player_deck = derkta.duplicate()
	rpc("receive_opponent_deck", derkta)


@rpc("any_peer")
func receive_opponent_deck(derkta: Array) -> void:
	if is_local_player:
		return
	deck_ref.player_deck = derkta
