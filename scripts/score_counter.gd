extends Node2D

const CARD_STATES = preload("res://scripts/card_states.gd")

var heart_label: Label
var club_label: Label
var spade_label: Label
var diamond_label: Label
var blocked_label: Label

var heart_val: int = 0
var club_val: int = 0
var spade_val: int = 0
var diamond_val: int = 0

var blocked_tween: Tween

func _ready() -> void:
	var font = load("res://assets/BigBlueTermPlusNerdFontMono-Regular.ttf")

	var container = HBoxContainer.new()
	container.position = Vector2(20, 20)
	add_child(container)

	heart_label = _make_label("♥ 0", Color(1, 0.2, 0.2), font)
	club_label = _make_label("♣ 0", Color(0.2, 1, 0.2), font)
	spade_label = _make_label("♠ 0", Color(0.6, 0.6, 1), font)
	diamond_label = _make_label("♦ x0", Color(1, 0.8, 0.2), font)

	container.add_child(heart_label)
	container.add_child(club_label)
	container.add_child(spade_label)
	container.add_child(_make_separator())
	container.add_child(diamond_label)

	blocked_label = Label.new()
	blocked_label.text = ""
	blocked_label.add_theme_font_size_override("font_size", 36)
	blocked_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1, 0.0))
	blocked_label.add_theme_font_override("font", font)
	blocked_label.position = Vector2(20, 90)
	add_child(blocked_label)


func _make_label(text: String, color: Color, font = null) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 48)
	label.custom_minimum_size = Vector2(200, 60)
	if font:
		label.add_theme_font_override("font", font)
	return label


func _make_separator() -> Control:
	var sep = VSeparator.new()
	sep.custom_minimum_size = Vector2(20, 60)
	return sep


func reset() -> void:
	heart_val = 0
	club_val = 0
	spade_val = 0
	diamond_val = 0
	_update_labels()


func _update_labels() -> void:
	heart_label.text = "♥ " + str(heart_val)
	club_label.text = "♣ " + str(club_val)
	spade_label.text = "♠ " + str(spade_val)
	diamond_label.text = "♦ x" + str(diamond_val)


func show_blocked(amount: int) -> void:
	if blocked_tween:
		blocked_tween.kill()

	if amount == 0:
		blocked_label.text = ""
		return

	blocked_label.text = "blocked " + str(amount) + " damage"
	blocked_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1, 1.0))

	blocked_tween = create_tween()
	blocked_tween.set_ease(Tween.EASE_IN)
	blocked_tween.set_trans(Tween.TRANS_CUBIC)

	blocked_tween.tween_interval(1.4)
	blocked_tween.tween_method(func(a: float):
		blocked_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1, a))
	, 1.0, 0.0, 0.5)


func animate_card(card: Node2D, suit: int, value: int) -> Signal:
	var tween = create_tween()
	tween.tween_property(card, "rotation_degrees", 15, 0.08)
	tween.tween_property(card, "rotation_degrees", -15, 0.08)
	tween.tween_property(card, "rotation_degrees", 0, 0.06)

	tween.tween_callback(func():
		match suit:
			CARD_STATES.SUIT.Heart:   heart_val += value
			CARD_STATES.SUIT.Club:    club_val += value
			CARD_STATES.SUIT.Spade:   spade_val += value
			CARD_STATES.SUIT.Diamond: diamond_val += 1
		_update_labels()
	)

	return tween.finished


func animate_hand_sequentially(card_data: Array, card_nodes: Array) -> void:
	reset()
	_sequence(card_data, card_nodes, 0)


func _sequence(card_data: Array, card_nodes: Array, index: int) -> void:
	if index >= card_data.size():
		return
	var suit = card_data[index][1]
	var rank = card_data[index][0]
	var card_node = card_nodes[index]

	var finished = animate_card(card_node, suit, rank)
	finished.connect(func():
		await get_tree().create_timer(0.1).timeout
		_sequence(card_data, card_nodes, index + 1)
	, CONNECT_ONE_SHOT)
