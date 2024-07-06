extends Control

@export var game_manager : GameManager

func _ready():
	hide()
	game_manager.connect("toggle_quest_paused",_on_quest_manager_toggle_quest_paused)

func _process(_delta):
	pass

func _on_quest_manager_toggle_quest_paused(is_paused : bool):
	if(is_paused):
		print_debug("PAUSED")
		show()
	else:
		hide()

func _on_resume_button_pressed():
	print_debug("RESUME PRESSED")
	game_manager.quest_paused = false


func _on_exit_button_pressed():
	get_tree().quit()
