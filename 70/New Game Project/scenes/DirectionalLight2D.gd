extends DirectionalLight2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotation += 0.001
	if energy >= 0.0:
		energy -= 0.001
