extends Node2D

const COLLISION_MASK_CARD = 1
const DEFAULT_CARD_MOVE_SPEED = preload("res://scripts/card_states.gd").DEFAULT_CARD_MOVE_SPEED


var screen_size
var value: int
var suit: int
var card_being_dragged
var is_hovering_on_card
var player_hand_reference

# Drag lag settings
const DRAG_SMOOTHNESS = 0.25  # Lower = more lag (0.1-0.3 is good range)

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		var target_pos = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)
		# Smooth follow instead of instant snap
		card_being_dragged.position = card_being_dragged.position.lerp(target_pos, DRAG_SMOOTHNESS)


func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1,1)


func finish_drag():
	card_being_dragged.scale = Vector2(1.05,1.05)

	# logic for slots if we did them lmao

	player_hand_reference.add_card_to_hand(card_being_dragged, 0.2)

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
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

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
