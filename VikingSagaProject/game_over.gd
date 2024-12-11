extends Control

@onready var restart_button = $RestartButton
@onready var quit_button = $QuitButton

func _ready():
	# Connect button signals
	restart_button.pressed.connect(_on_restart_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
