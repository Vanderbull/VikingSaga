extends Node

var Fullscreen = true
var base_resolution = Vector2i(1152, 648)

func _ready():
	Fullscreen = DisplayServer.window_get_mode()
	$Control/Fullscreen.button_pressed = Fullscreen
	set_viewport_size(Vector2(1280, 720))
	#print(base_resolution)
#
	#var current_resolution = DisplayServer.window_get_size()
	#print(current_resolution)
	#var scale_factor = Vector2(current_resolution) / Vector2(base_resolution)
	#print(scale_factor)
	#print(Vector2(1920,1080) / Vector2(1152, 648))
	#scale_factor = Vector2(min(scale_factor.x, scale_factor.y), min(scale_factor.x, scale_factor.y))
#
	## Apply this scale factor to your root node or specific viewports
	#print(scale_factor)
	#$Control.scale = scale_factor'
	
func set_viewport_size(size: Vector2):
	var viewport = get_viewport()
	viewport.size = size # Vector2(1920, 1080)
	print(get_viewport().size)

func _on_display_resolution_item_selected(index):
	print(str(index))
	if index == 0:
		set_viewport_size(Vector2(1920, 1080))
		#$Control.scale = Vector2(1.6,1.6)
		for child in get_children():
			if child is Control:
				var control = child as Control
				control.size *= 1.6
				#control.position *= 1.6
				print("Control")
		for child in get_children():
			if child is TextureRect:
				var control = child as TextureRect
				control.size *= 1.6
				#control.position *= 1.6
				print("TextureRect")
		pass
		#print(base_resolution)
		#DisplayServer.window_set_size(Vector2(1920, 1080))
		#var current_resolution = DisplayServer.window_get_size()
		#print(current_resolution)
		#var scale_factor = Vector2(base_resolution) / Vector2(current_resolution)
		#print(scale_factor)
		#print(Vector2(1920,1080) / Vector2(1152, 648))
		#scale_factor = Vector2(min(scale_factor.x, scale_factor.y), min(scale_factor.x, scale_factor.y))
		#scale_factor= Vector2(1,1)
		#var viewport_size = get_viewport().size
		#viewport_size = Vector2i(1920,1080)
		#scale_factor = viewport_size / base_resolution
		#$Control.scale = Vector2(scale_factor.x, scale_factor.y)
		## Apply this scale factor to your root node or specific viewports
		#print(scale_factor)
		##$Control.scale = scale_factor
		
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		#Fullscreen = DisplayServer.window_get_mode()
	if index == 1:
		set_viewport_size(Vector2(640, 480))
		$Control.scale = Vector2(0.6,0.6)
		for child in get_children():
			if child is Control:
				var control = child as Control
		for child in get_children():
			if child is TextureRect:
				var control = child as TextureRect
				control.size *= 0.6
				#control.position *= 1.6
				print("TextureRect")
		pass
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		#Fullscreen = DisplayServer.window_get_mode()

var fullscreen = true
func _on_fullscreen_toggled(button_pressed):
	var Resolution = $Control/DisplayResolution.get_selected_id()
	if Resolution == 0:
		DisplayServer.window_set_size(Vector2(1920, 1080))
	else:
		DisplayServer.window_set_size(Vector2(640, 480))
	
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		print(str(button_pressed))
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED,0)
		print(str(button_pressed))


func _on_save__exit_pressed():
	pass
	#get_tree().change_scene_to_file("res://menu.tscn")


func _on_cancel_pressed():
	pass
	#get_tree().change_scene_to_file("res://menu.tscn")
