extends Node2D

const PORT = 9967
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()
@export var player_field_scene : PackedScene

func _on_host_button_pressed() -> void:
	disable_buttons()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	var player_scene = player_field_scene.instantiate()
	player_scene.name = str(multiplayer.get_unique_id())
	add_child(player_scene)
	$GameLoop.set_scoring_refs(multiplayer.get_unique_id(), player_scene)

func _on_join_button_pressed() -> void:
	disable_buttons()
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	var player_scene = player_field_scene.instantiate()
	player_scene.name = str(multiplayer.get_unique_id())
	add_child(player_scene)
	$GameLoop.set_scoring_refs(multiplayer.get_unique_id(), player_scene)

func _on_peer_connected(peer_id):
	var opponent_scene = player_field_scene.instantiate()
	opponent_scene.name = str(peer_id)
	add_child(opponent_scene)
	$GameLoop.set_scoring_refs(peer_id, opponent_scene)

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false

	$DiscardButton.visible = true
	$PlayButton.visible = true
	$ScoreCounter.visible = true
