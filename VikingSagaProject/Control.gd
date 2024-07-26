extends Control

@export var popup: Popup
@export var popup_label: Label

# The key to trigger the popup, for example, the "P" key
@export var trigger_key: String = "P"

func _ready():
	# Initialize anything if necessary
	pass

func _input(event: InputEvent):
	if event is InputEventKey:
		# Check if the event is a key press and matches the trigger key
		#if event.pressed and event.physical_keycode == @Godot.KeyList.@(trigger_key):
			#_show_popup()
			if $"../Quests/VBoxContainer/Clock".get_timeofday() == "NIGHT":
				_show_popup()
			pass

func _show_popup():
	# Display the popup and set the label's text
	popup.popup_centered()
	#popup_label.text = "Hello, this is a popup triggered by the %s key!" % trigger_key
	popup_label.text = "Its nightime and you should be sleeping, you cant move until 06:00"
