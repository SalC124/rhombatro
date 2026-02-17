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


func _on_join_button_pressed() -> void:
	disable_buttons()
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	var evil_scene = evil_field_scene.instantiate()
	add_child(evil_scene)
	player_scene.client_set_up()

func _on_peer_connected(peer_id):
	var evil_scene = evil_field_scene.instantiate()
	add_child(evil_scene)
	get_node("PlayerField").host_set_up()

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
