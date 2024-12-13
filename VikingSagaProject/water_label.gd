extends Label
@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../../.."

func update_text(_current_water, max_water):
		text = """%d / %d""" % [game_manager.playerData.PlayerWater, max_water]
