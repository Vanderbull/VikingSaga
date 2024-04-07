extends Control

signal opened
signal closed

var isOpen: bool = false

func open():
	visible = true
	isOpen = true
	opened.emit()
	
func close():
	visible = false
	isOpen = false
	closed.emit()
