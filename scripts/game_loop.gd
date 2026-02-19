extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
var scoring_refs = {}

var played_hands = {}
var round_ready_received = {}

func set_scoring_refs(peer_id: int, ref: Node) -> void:
	scoring_refs[peer_id] = ref
	ref.owner_peer_id = peer_id
	ref._ready_setup()
	ref.death.connect(_on_player_death)
	ref.round_ready.connect(_on_round_ready)
	if scoring_refs.size() == 2: # make sure this is the second one before starting
		draw_initial_hands()
	if peer_id == multiplayer.get_unique_id():
		get_parent().get_node("InputManager").setup(
			ref.get_node("CardManager"),
			ref.get_node("Deck")
		)


func _on_player_death(peer_id: int) -> void:
	print("player ", peer_id, " died lmao")
	# TODO: end screen


func _on_round_ready(peer_id: int) -> void:
	round_ready_received[peer_id] = true


func draw_initial_hands() -> void:
	for feinld in scoring_refs.values():
		feinld.generate_and_share_deck()
		feinld.get_node("Deck").draw_card(CARD_STATES.DEFAULT_HAND_SIZE)


func get_local_field() -> Node:
	return scoring_refs.get(multiplayer.get_unique_id(), null) # me when its just like python


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func button_update():
	var field = get_local_field()
	if field == null:
		return # juuuuuust in case
	var hand = field.player_hand_ref
	if hand.selected_cards.size() == 0:
		get_parent().get_node("DiscardButton").disabled = true
		get_parent().get_node("PlayButton").disabled = true
	else:
		get_parent().get_node("DiscardButton").disabled = false
		get_parent().get_node("PlayButton").disabled = hand.rhombuses == 0

func submit_played_hand(peer_id: int, card_data: Array) -> void:
	played_hands[peer_id] = card_data
	if played_hands.size() == 2:
		i_used_to_have_hoop_dreams_until_i_found_out_that_there_were_other_ways_to_score()

@rpc("any_peer")
func rpc_submit_played_hand(peer_id: int, card_data: Array) -> void:
	submit_played_hand(peer_id, card_data)


func i_used_to_have_hoop_dreams_until_i_found_out_that_there_were_other_ways_to_score():
	var peer_ids = scoring_refs.keys()
	var id_a = peer_ids[0]
	var id_b = peer_ids[1]

	var hand_a = played_hands[id_a]
	var hand_b = played_hands[id_b]

	for field in scoring_refs.values():
		if not field.is_local_player:
			for card in field.opponent_cards_in_play:
				card.reveal_opp_card()

	await get_tree().create_timer(0.3).timeout


	var score_counter = get_parent().get_node("ScoreCounter")
	var local_field = get_local_field()
	var local_id = multiplayer.get_unique_id()
	var local_hand_data = played_hands[local_id]
	var local_card_nodes = local_field.player_cards_in_play

	score_counter.animate_hand_sequentially(local_hand_data, local_card_nodes)

	var total_duration = local_hand_data.size() * 0.32
	await get_tree().create_timer(total_duration).timeout

	var result_a = calculate_hand(hand_a)
	var result_b = calculate_hand(hand_b)

	fisticuffs(id_a, result_a, id_b, result_b)	# shrimp on the barbie
	fisticuffs(id_b, result_b, id_a, result_a)	# barbie on the shrimp

	scoring_refs[id_a].heal(result_a.hearts)
	scoring_refs[id_b].heal(result_b.hearts)

	played_hands.clear()

	if scoring_refs[id_a].hp == 0 or scoring_refs[id_b].hp == 0: # bail if hes already dead
		return

	round_ready_received.clear()
	for field in scoring_refs.values():
		field.discard_from_played_hand(field.player_cards_in_play.duplicate())

	while round_ready_received.size() < 2:
		await get_tree().process_frame # wait for end of redraws

	for peer_id in scoring_refs:
		if not scoring_refs[peer_id].has_playable_hand():
			_on_player_death(peer_id)
			return


func calculate_hand(card_data: Array):
	var hearts = 0
	var clubs = 0
	var spades = 0
	var diamonds = 0

	for card in card_data:
		var rank = card[0]
		var suit = card[1]
		var value = rank	# jack=11, queen=12, king=13, ace=14
		match suit:
			CARD_STATES.SUIT.Heart:   hearts += value
			CARD_STATES.SUIT.Club:	  clubs += value
			CARD_STATES.SUIT.Diamond: diamonds += 1
			CARD_STATES.SUIT.Spade:   spades += value

	return {
		"hearts": hearts * diamonds,
		"clubs": clubs * diamonds,
		"spades": spades * diamonds,
		"diamonds": diamonds
	}


func fisticuffs(attacker_id: int, attacker_result, defender_id: int, defender_result) -> void:
	var defender = scoring_refs[defender_id]
	var shield = defender_result.clubs
	var damage = max(0, attacker_result.spades - shield)
	defender.take_damage(damage)

func _on_discard_pressed() -> void:
	var field = get_local_field()
	if field == null:
		return
	field._on_discard_pressed()


func _on_play_button_pressed() -> void:
	var field = get_local_field()
	if field == null:
		return
	field._on_play_hand_pressed()
