extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Root:", self)
	print("Root type:", self.get_class())
	print("Stretch mode:", ProjectSettings.get_setting("display/window/stretch/mode"))
	print("Stretch aspect:", ProjectSettings.get_setting("display/window/stretch/aspect"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
