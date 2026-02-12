extends Node

var player_played = false
var opponent_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../PlayHand".disabled=false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func opponent_turn():
	pass


func _on_play_hand_pressed() -> void:
	$"../PlayHand".disabled=true
	
