extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released
signal right_mouse_button_clicked
signal right_mouse_button_released

const COLLISION_MASK_CARD := 1
const COLLISION_MASK_DECK := 4
const DEFAULT_HAND_SIZE := preload("res://scripts/card_states.gd").DEFAULT_HAND_SIZE

var card_manager_reference
var deck_reference


func _process(delta: float) -> void:
	pass


func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print()
			print("lmb pressed")
			raycast_at_cursor(event)
		else:
			print("lmb released")
			emit_signal("left_mouse_button_released")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			raycast_at_cursor(event)

func raycast_at_cursor(input):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position= get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	print("result: ", result)


	if result.size()>0:
		var result_collision_mask = result[0].collider.collision_mask # r[0] gives RID
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found = get_card_with_highest_z_index(result)
			print("card found", card_found)


			if card_found:
				if input.button_index == MOUSE_BUTTON_LEFT:
					card_manager_reference.start_drag(card_found)
				elif input.button_index == MOUSE_BUTTON_RIGHT:
					card_found.discard()
		elif result_collision_mask == COLLISION_MASK_DECK:
			deck_reference.deck_clicked()


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
