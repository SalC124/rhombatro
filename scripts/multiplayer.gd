extends Node2D

const PORT = 9967
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()
@export var player_field_scene : PackedScene
@export var evil_field_scene : PackedScene


func _on_host_button_pressed() -> void:
	disable_buttons()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	player_setup()
	$GameLoop.set_scoring_refs(
		player_scene.get_node("Hand"),
		null
	)



func _on_join_button_pressed() -> void:
	disable_buttons()
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	var evil_scene = evil_field_scene.instantiate()
	add_child(evil_scene)
	player_setup()
	evil_setup()
	$GameLoop.set_scoring_refs(
		player_scene.get_node("Hand"),
		evil_scene.get_node("Hand")
	)

func _on_peer_connected(_peer_id):
	var evil_scene = evil_field_scene.instantiate()
	add_child(evil_scene)
	evil_setup()
	$GameLoop.set_scoring_refs(null, evil_scene.get_node("Hand"))

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false


func player_setup():
	while true:
		await get_tree().create_timer(0.2).timeout
		if multiplayer.get_peers().size() > 0:
			break
	$"PlayerField/Deck".draw_initial_hand()


func evil_setup():
	while true:
		await get_tree().create_timer(0.2).timeout
		if multiplayer.get_peers().size() > 0:
			break
	$"EvilField/Deck".draw_initial_hand()
