extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")
	hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	show()
	pass
