extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
var scoring_refs = {}

var player_1_played = false
var player_2_played = false

var player_1_cards_in_play = []
var player_2_cards_in_play = []

func set_scoring_refs(peer_id: int, ref: Node) -> void:
	scoring_refs[peer_id] = ref
	ref.owner_peer_id = peer_id


# func player_1_setup(player_id):
# 	while true:
# 		await get_tree().create_timer(0.2).timeout
# 		if multiplayer.get_peers().size() > 0:
# 			break
# 	$"PlayerField/Deck".draw_initial_hand()


# func evil_setup():
# 	while true:
# 		await get_tree().create_timer(0.2).timeout
# 		if multiplayer.get_peers().size() > 0:
# 			break
# 	$"EvilField/Deck".draw_initial_hand()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_discard_pressed() -> void:
	pass # Replace with function body.


func _on_play_button_pressed() -> void:
	pass # Replace with function body.
