extends Node2D

const CardTypes = preload("res://scripts/card_types.gd")

signal hovered(card: Node2D)
signal hovered_off(card: Node2D)
signal speed_changed(card: Node2D, speed: float)

var prev_x: float
var starting_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All cards must be a child of CardManager or this will err
	#
	# you MUST run the Main scene or you get a "Window Parent" error
	# if you run as a Card, it'll have no parent of CardManager
	get_parent().connect_card_signals(self)
	prev_x = global_position.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called after movement (after process). necessary to get delta_x
func _physics_process(_delta: float) -> void:
	var current_x: float = global_position.x
	var delta_x = current_x - prev_x

	# Emit speed for tilt calculation
	emit_signal("speed_changed", self, delta_x)

	prev_x = current_x

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
