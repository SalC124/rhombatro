extends CanvasLayer

const CARD_STATES = preload("res://scripts/card_states.gd")

var bar
var label
var tween

func _ready() -> void:
	layer = 10  # render on top of everything

	var container = HBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	container.position = Vector2(24, 128)
	container.add_theme_constant_override("separation", 12)
	add_child(container)

	label = Label.new()
	label.text = "HP"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 0.35, 0.35))
	var font = load("res://assets/BigBlueTermPlusNerdFontMono-Regular.ttf")
	label.add_theme_font_override("font", font)

	container.add_child(label)

	bar = ProgressBar.new()
	bar.min_value = 0
	bar.max_value = CARD_STATES.STARTING_HP
	bar.value = CARD_STATES.STARTING_HP
	bar.custom_minimum_size = Vector2(320, 32)
	bar.show_percentage = false

	# Style: filled portion
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.85, 0.15, 0.15)
	fill_style.corner_radius_top_left = 6
	fill_style.corner_radius_top_right = 6
	fill_style.corner_radius_bottom_left = 6
	fill_style.corner_radius_bottom_right = 6
	bar.add_theme_stylebox_override("fill", fill_style)

	# Style: background track
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15)
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_left = 6
	bg_style.corner_radius_bottom_right = 6
	bar.add_theme_stylebox_override("background", bg_style)

	container.add_child(bar)

	var hp_label = Label.new()
	hp_label.name = "HPValueLabel"
	hp_label.text = str(CARD_STATES.STARTING_HP) + " / " + str(CARD_STATES.STARTING_HP)
	hp_label.add_theme_font_size_override("font_size", 24)
	hp_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	hp_label.add_theme_font_override("font", font)

	container.add_child(hp_label)


func animate_to(new_hp: int) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	var old_val = bar.value

	# Flash white briefly if damage taken
	if new_hp < old_val:
		var fill_style_white = StyleBoxFlat.new()
		fill_style_white.bg_color = Color(1, 1, 1)
		fill_style_white.corner_radius_top_left = 6
		fill_style_white.corner_radius_top_right = 6
		fill_style_white.corner_radius_bottom_left = 6
		fill_style_white.corner_radius_bottom_right = 6
		bar.add_theme_stylebox_override("fill", fill_style_white)

		tween.tween_callback(func():
			var fill_style = StyleBoxFlat.new()
			fill_style.bg_color = Color(0.85, 0.15, 0.15)
			fill_style.corner_radius_top_left = 6
			fill_style.corner_radius_top_right = 6
			fill_style.corner_radius_bottom_left = 6
			fill_style.corner_radius_bottom_right = 6
			bar.add_theme_stylebox_override("fill", fill_style)
		).set_delay(0.12)

	tween.tween_property(bar, "value", float(new_hp), 0.45)
	tween.parallel().tween_method(func(v: float):
		get_node("HBoxContainer/HPValueLabel").text = str(roundi(v)) + " / " + str(CARD_STATES.STARTING_HP)
	, float(old_val), float(new_hp), 0.45)
