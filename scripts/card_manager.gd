extends Node2D

const COLLISION_MASK_CARD = 1
const CARD_STATES = preload("res://scripts/card_states.gd")


var screen_size
var value: int
var suit: int
var card_being_dragged
var is_hovering_on_card
var player_hand_reference

var relative_mouse_pos	# position of mouse on the card so that
						# clicking on a corner wont move the card there

var first_click_pos

signal select(card: Node2D)


func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position() - (relative_mouse_pos * 2) # times 2 for scale of 2
		var target_pos = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)
		# Smooth follow instead of instant snap
		card_being_dragged.position = card_being_dragged.position.lerp(target_pos, CARD_STATES.DRAG_SMOOTHNESS)


func start_drag(card):
	card_being_dragged = card
	relative_mouse_pos = card.get_local_mouse_position() # on the card
	card.z_index = CARD_STATES.CARD_DRAG_Z_INDEX
	card.scale = Vector2(2,2)
	first_click_pos = get_global_mouse_position()


func finish_drag():
	card_being_dragged.scale = Vector2(2.1,2.1)

	# logic for slots if we did them lmao

	player_hand_reference.add_card_to_hand(card_being_dragged, CARD_STATES.CARD_DRAW_SPEED)


	var glob_mos = get_global_mouse_position()
	if (
		(
			(first_click_pos.x - 10) < glob_mos.x
			and (first_click_pos.x + 10) > glob_mos.x
		) and (
			(first_click_pos.y - 10) < glob_mos.y
			and (first_click_pos.y + 10) > glob_mos.y
		)
	):
		emit_signal("select", card_being_dragged)

	card_being_dragged = null


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	card.connect("speed_changed", on_speed_changed_card)


func on_left_click_released():
	if card_being_dragged:
		finish_drag()


func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)

		# check if hovered off card straight onto another card
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false


func on_speed_changed_card(card, speed):
	const MAX_TILT = 22.5
	const MAX_SPEED = 50.0
	const MIN_DURATION = 0.01
	const MAX_DURATION = 0.1

	var speed_abs = abs(speed)
	var tilt_amount = clamp(speed_abs / MAX_SPEED, 0.0, 1.0) * MAX_TILT
	var tilt_angle = tilt_amount * sign(speed) * -1

	var duration = lerp(MAX_DURATION, MIN_DURATION, clamp(speed_abs / MAX_SPEED, 0.0, 1.0))

	var tween = create_tween()
	tween.tween_property(card, "rotation_degrees", tilt_angle, duration)


func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(2.1, 2.1)
		card.z_index = CARD_STATES.BASE_HOVER_Z_INDEX
	else:
		card.scale = Vector2(2, 2)
		card.z_index = card.zed_index


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position= get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size()>0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
