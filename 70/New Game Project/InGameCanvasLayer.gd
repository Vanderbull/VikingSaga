extends CanvasLayer

@onready var inventory = $InventoryGui

func _ready():
	inventory.close()
	
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()
