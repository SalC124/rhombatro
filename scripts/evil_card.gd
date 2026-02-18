extends Node2D

const CARD_STATES = preload("res://scripts/card_states.gd")

signal hovered(card: Node2D)
signal hovered_off(card: Node2D)
signal speed_changed(card: Node2D, speed: float)


var prev_x: float
var starting_position

var rank: int
var suit: int
@onready var card_image: Sprite2D = $CardImage
@onready var card_outline: Sprite2D = $CardOutline
@onready var card_butt: Sprite2D = $CardButt

var zed_index: int

var y_offset: int = 0

func setup(r: int, s: int):
	rank = r
	suit = s

	$CardImage.region_enabled = true
	$CardImage.texture = load("res://assets/notbalatro.png")
	$CardImage.region_rect = Rect2((r-2)*71, s*95, 71, 95)

	$CardOutline.region_enabled = true
	$CardOutline.texture = load("res://assets/notbalatrooutlines.png")
	$CardOutline.region_rect = Rect2((1)*71, 0*95, 71, 95)
	
	$CardButt.region_enabled = true
	$CardButt.texture = load("res://assets/notbalatrooutlines.png")
	$CardButt.region_rect = Rect2((0)*71, 0*95, 71, 95)

	self.z_as_relative = false
	$CardImage.z_index = CARD_STATES.BASE_CARD_Z_INDEX+1
	$CardOutline.z_index = CARD_STATES.BASE_CARD_Z_INDEX
	$CardButt.z_index = CARD_STATES.BASE_CARD_Z_INDEX+2

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

func discard():
	$CardImage.visible = false
	$CardOutline.visible = false
	$CardButt.visible = false
	#$"../../PlayerHand".remove_card_from_hand(self)
