extends Node2D

const STARTING_HEALTH = 100

func host_set_up():
	get_parent().get_node("EvilField/EvilDeck").deck_size = 52 
	$Deck.draw_initial_hand()
	
	
	
func client_set_up():
	get_parent().get_node("EvilField/EvilDeck").deck_size = 52 
	while true:
		await get_tree().create_timer(0.2).timeout
		if multiplayer.get_peers().size() > 0:
			break
	$Deck.draw_initial_hand()
