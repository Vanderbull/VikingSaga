extends Label

# Reference to the Label node
#@export var time_label: Label

func _ready():
	# Set up the clock to update every second
	set_process(true)

func _process(_delta: float) -> void:
	# Get the current time
	var time = Time.get_time_dict_from_system()
	
	## Format the time as a 24-hour clock (HH:MM:SS)
	#var hours = str(time["hour"]).pad_zero(2)
	#var minutes = str(time["minute"]).pad_zero(2)
	#var seconds = str(time["second"]).pad_zero(2)
	
		# Format the time as a 24-hour clock (HH:MM:SS)
	var hours = "%02d" % time["hour"]
	var minutes = "%02d" % time["minute"]
	var seconds = "%02d" % time["second"]
	
	# Determine day or night
	var day_or_night = ""
	if time["hour"] >= 6 and time["hour"] < 18:
		day_or_night = "DAY"
	else:
		day_or_night = "NIGHT"
		
	text = "%s:%s:%s %s" % [hours, minutes, seconds, day_or_night]
	
func get_timeofday():
		# Get the current time
	var time = Time.get_time_dict_from_system()
	# Determine day or night
	#var day_or_night = ""
	if time["hour"] >= 6 and time["hour"] < 18:
		return "DAY"
	else:
		return "NIGHT"
