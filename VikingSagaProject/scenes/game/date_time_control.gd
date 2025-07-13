extends Control


var current_time_seconds: float = 0.0
var time_speed: float = 10000.0  # 100× faster than real time
var days_passed: int = 0       # Counts the number of full days passed

func _process(delta):
	current_time_seconds += delta * time_speed

	# Wrap around after 24 hours
	if current_time_seconds >= 86400:
		current_time_seconds -= 86400
		days_passed += 1  # ⬅️ Increment day counter
		#print("New day! Days passed: ", days_passed)
		$VBoxContainer/Day.text = "DAY: %s" % [days_passed]
	update_clock_display()

func update_clock_display():
	var hours = int(current_time_seconds / 3600)
	var minutes = int(fmod(current_time_seconds, 3600) / 60)

	var time_string = "%02d:%02d" % [hours, minutes]
	#print(time_string)
	$VBoxContainer/Time.text = "%02d:%02d" % [hours, minutes]

# Optional: Change clock speed with a function or input
func set_clock_speed(new_speed: float):
	time_speed = new_speed
	
