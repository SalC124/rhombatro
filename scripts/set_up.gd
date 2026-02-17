extends Node2D

const STARTING_HEALTH = 100

func host_set_up():
	while true:
		await get_tree().create_timer(0.2).timeout
		if multiplayer.get_peers().size() > 0:
			break
	$Deck.draw_initial_hand()
	
	
	
func client_set_up():
	while true:
		await get_tree().create_timer(0.2).timeout
		if multiplayer.get_peers().size() > 0:
			break
	$Deck.draw_initial_hand()
