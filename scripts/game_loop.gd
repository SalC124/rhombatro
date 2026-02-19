extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
var scoring_refs = {}

func set_scoring_refs(peer_id: int, ref: Node) -> void:
	scoring_refs[peer_id] = ref
	ref.owner_peer_id = peer_id
	ref._ready_setup()
	if scoring_refs.size() == 2: # make sure this is the second one before starting
		draw_initial_hands()
	if peer_id == multiplayer.get_unique_id():
		get_parent().get_node("InputManager").setup(
			ref.get_node("CardManager"),
			ref.get_node("Deck")
		)


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
	button_update() # this is only temporary. in reality, it should run every change in selection


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
