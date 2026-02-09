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

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			raycast_at_cursor(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			raycast_at_cursor(event)

func raycast_at_cursor(input):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position= get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found = result[0].collider.get_parent()
			if card_found:
				if input.button_index == MOUSE_BUTTON_LEFT:
					card_manager_reference.start_drag(card_found)
				elif input.button_index == MOUSE_BUTTON_RIGHT:
					card_found.discard()
		elif result_collision_mask == COLLISION_MASK_DECK:
			deck_reference.draw_card(DEFAULT_HAND_SIZE)
