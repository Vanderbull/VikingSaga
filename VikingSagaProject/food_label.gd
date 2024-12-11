extends Label
@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../../.."

func update_text(_current_food, max_food):
		text = """%d / %d""" % [game_manager.playerData.PlayerFood, max_food]
