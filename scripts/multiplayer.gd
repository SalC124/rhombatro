extends Node2D

const PORT = 9967
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()
@export var player_field_scene : PackedScene
@export var evil_field_scene : PackedScene
signal connect_and_such_also_f_u

func _on_host_button_pressed() -> void:
	disable_buttons()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	$GameLoop.set_scoring_refs(multiplayer.get_unique_id(), player_scene)
	emit_signal("connect_and_such_also_f_u")



func _on_join_button_pressed() -> void:
	disable_buttons()
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	var player_scene = player_field_scene.instantiate()
	var evil_scene = evil_field_scene.instantiate()
	add_child(player_scene)
	add_child(evil_scene)
	$GameLoop.set_scoring_refs(multiplayer.get_unique_id(), player_scene)
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(peer_id):
	var evil_scene = evil_field_scene.instantiate()
	add_child(evil_scene)
	$GameLoop.set_scoring_refs(peer_id, evil_scene)

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
