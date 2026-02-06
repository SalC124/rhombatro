extends Node2D

const CARD_SCENE_PATH = "res://scenes/Card.tscn"
const CARD_STATES = preload("res://scripts/card_states.gd")

var player_deck = ["2Hrt", "2Hrt", "2Hrt"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)

	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false

	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	new_card.name = "Caehrd"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_STATES.CARD_DRAW_SPEED)
