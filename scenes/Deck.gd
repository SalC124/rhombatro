extends Node2D

var player_deck = ["2Hrt", "2Hrt", "2Hrt"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func draw_card():
	print("draw")
	#var card_scene = preload(CARD_SCENE_PATH)
	#for i in range(HAND_COUNT):
		#var new_card = card_scene.instantiate()
		#$"../CardManager".add_child(new_card)
		#new_card.name = "Caehrd"
		#add_card_to_hand(new_card)
