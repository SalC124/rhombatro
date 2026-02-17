extends Node

const CARD_STATES = preload("res://scripts/card_states.gd")
var player_scoring_ref = null
var evil_scoring = null

var player_played = false
var opponent_played = false

var player_cards_in_play = []
var opponent_cards_in_play = []

func set_scoring_refs(player_ref, evil_ref) -> void:
	if player_ref:
		player_scoring_ref = player_ref
	if evil_ref:
		evil_scoring = evil_ref


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
