extends Control

var isOpen: bool = false

func open():
	visible = true
	isOpen = true
		
func close():
	visible = false
	isOpen = false
