extends Control

@export var popup: Popup
@export var popup_label: Label
@export var typing_timer: Timer
# The text to display in the popup
@export var full_text: String = "This is the text that will appear character by character."
# The delay between each character
@export var typing_delay: float = 0.15
# The key to trigger the popup, for example, the "P" key
@export var trigger_key: String = "P"

func _ready():
	pass
	#print("Control _ready()...")
	## Connect the timer's timeout signal to a function
	#typing_timer.timeout.connect(_on_typing_timer_timeout)
	## Initialize the popup with empty text
	#popup_label.text = ""
	## Set the timer's wait time
	#typing_timer.wait_time = typing_delay
	## Start typing when the scene is ready
	#_show_popup_with_typing()
	
func _show_popup_with_typing():
	pass
	## Start the popup and the timer
	#popup.popup_centered()
	#typing_timer.stop()  # Stop any previous timer state
	#popup_label.text = ""
	#typing_timer.start()
	
func _on_typing_timer_timeout():
	pass
	## Add one character to the label text
	#if popup_label.text.length() < full_text.length():
		#popup_label.text += full_text[popup_label.text.length()]
	#else:
		##popup_label.text = ""
		## Stop the timer when all characters are typed
		#typing_timer.stop()

func _input(_event: InputEvent):
	pass
	#if event is InputEventKey:
		## Check if the event is a key press and matches the trigger key
		##if event.pressed and event.physical_keycode == @Godot.KeyList.@(trigger_key):
			##_show_popup()
			##if $"../Quests/VBoxContainer/Clock".get_timeofday() == "NIGHT":
				##_show_popup()
			#pass

func _show_popup():
	pass
	## Display the popup and set the label's text
	#popup.popup_centered()
	##popup_label.text = "Hello, this is a popup triggered by the %s key!" % trigger_key
	#popup_label.text = "Its nightime and you should be sleeping, you cant move until 06:00"
