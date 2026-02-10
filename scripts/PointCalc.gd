extends Node2D

@onready var label = $Label
@onready var HAND_REF= $"../PlayerHand"
var SELECTED= HAND_REF.selected_cards
@onready var CARD_REF= 9
var total_heart 
var total_club
var total_spade
var total_diamond

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../CardManager".connect("select", on_select)



func on_select(_card) -> void:
	
	total_heart=0
	total_club=0
	total_spade=0
	total_diamond=0
	for i in range(0,SELECTED.size()):
		if SELECTED[i].suit==0:
			total_heart+=SELECTED[i].rank
		elif SELECTED[i].suit==1:
			total_club+=SELECTED[i].rank
		elif SELECTED[i].suit==2:
			total_club+=1
		elif SELECTED[i].suit==3:
			total_spade+=SELECTED[i].rank
	if total_diamond==0:
		total_diamond=1;
	label.text="+Health: " + total_heart*total_diamond + "\n +Shield: " +total_club*total_diamond + "\n +Attack: " +total_spade*total_diamond
