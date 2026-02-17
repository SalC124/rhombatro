extends Node2D

const STARTING_HEALTH = 100

func host_set_up():
	get_parent().get_node("EvilField/EvilDeck").deck_size = 52 
	$Deck.draw_initial_hand()
	
	
	
func client_set_up():
	get_parent().get_node("EvilField/EvilDeck").deck_size = 52 
	$Deck.draw_initial_hand()
