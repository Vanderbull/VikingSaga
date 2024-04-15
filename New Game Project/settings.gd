extends Control

var Fullscreen = true

func _ready():
	Fullscreen = DisplayServer.window_get_mode()
	$Fullscreen.button_pressed = Fullscreen

func _on_display_resolution_item_selected(index):
	print(str(index))
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED,0)
		Fullscreen = DisplayServer.window_get_mode()
	if index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		Fullscreen = DisplayServer.window_get_mode()


func _on_fullscreen_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		print(str(button_pressed))
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED,0)
		print(str(button_pressed))


func _on_save__exit_pressed():
	#get_tree().change_scene_to_file("res://menu.tscn")


func _on_cancel_pressed():
	#get_tree().change_scene_to_file("res://menu.tscn")
