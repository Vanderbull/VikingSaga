extends CanvasLayer

@onready var globals = get_node("/root/Globals")
@onready var HidesLabel = $CenterContainer2/VBoxContainer/Hides
@onready var WarriorsLabel = $CenterContainer2/VBoxContainer/Warriors
@onready var FarmersLabel = $CenterContainer2/VBoxContainer/Farmers
@onready var ThrallsLabel = $CenterContainer2/VBoxContainer/Thralls
@onready var GoldLabel = $CenterContainer2/VBoxContainer/Gold
@onready var RumorsLabel = $Rumors

@onready var PlayerHidesLabel = $Container/Player/Hides
@onready var PlayerWarriorsLabel = $Container/Player/Warriors
@onready var PlayerFarmersLabel = $Container/Player/Farmers
@onready var PlayerThrallsLabel = $Container/Player/Thralls
@onready var PlayerGoldLabel = $Container/Player/Gold

@onready var hides = 100
@onready var gold = 100
@onready var thralls = 100
@onready var farmers = 100
@onready var warriors = 100

# Reference: https://litrpgreads.com/blog/rpg/100-dnd-random-rumors-in-a-tavern
@export  var RumorDictionary = {
	0 : "You hear that the local Lord Tom Hoppenstance is making a pilgrimage to the local temple to ask the gods to bless his new sword, the one he got from the last dragon he killed.",
	1 : "Rumors are going around about a lost treasure hidden in the local catacombs.",
	2 : "The local woods are haunted by the ghost of an old hag who takes care of her lost goats.",
	3 : "People are complaining about the smell coming from the local tannery.",
	4 : "A local merchant brought back a strange seed from his last trip to the city. He planted it and is now growing a giant beanstalk that smells like rotting meat.	",
	5 : "A man has been chasing his wife with a frying pan.",
	6 : "A man was seen walking down the local road with a chicken on his head singing about how he was the king of the world.",
	7 : "The local mayor has been seen in the streets with a big feather sticking out of his backside.",
	8 : "A man was seen in the streets dressed in a barrel and asking for spare change for a good cause.",
	9 : "A half orc was seen running around the streets with a pig on his head.",
	10 : "The local Lord John of the manor has been seen walking around with a two headed chicken on his shoulder.	",
	11 : "The local butcher has been selling tainted chicken.",
	12 : "A man has been walking around in the streets talking to a piece of cloth that looks like a man’s face.",
	13 : "A man was seen walking around the streets, warning about an upcoming zombie invasion.",
	14 : "The local fortune teller says that the King is going to be killed by a man dressed in green."
	}

func _ready():
	RumorsLabel.visible = false

func _on_exit_button_pressed():
	globals.player_position.x -= 100
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_buy_hide_pressed():
	gold += 1
	globals.PlayerGold += 1
	PlayerGoldLabel.text = "Gold: " + str(globals.PlayerGold)
	GoldLabel.text = "Gold: " + str(gold)
	hides -= 1
	globals.PlayerHides += 1
	HidesLabel.text = "Hides: " + str(hides)
	globals.PlayerHides += 1
	PlayerHidesLabel.text = "Player Hides: " + str(globals.PlayerHides)
	
func _on_recruit_warrior_pressed():
	gold += 1
	globals.PlayerGold -= 1
	GoldLabel.text = "Gold: " + str(gold)
	PlayerGoldLabel.text = " Player Gold: " + str(globals.PlayerGold)
	warriors -= 1
	WarriorsLabel.text = "Warriors: " + str(warriors)
	globals.PlayerWarriors += 1
	PlayerWarriorsLabel.text = "Player Warriors: " + str(globals.PlayerWarriors)

func _on_sell_hide_pressed():
	gold -= 1
	globals.PlayerGold += 1
	GoldLabel.text = "Gold: " + str(gold)
	PlayerGoldLabel.text = " Player Gold: " + str(globals.PlayerGold)
	hides += 1
	HidesLabel.text = "Hides: " + str(hides)
	globals.PlayerHides += 1
	PlayerHidesLabel.text = "Player Hides: " + str(globals.PlayerHides)

func _on_recruit_farmer_pressed():
	gold += 1
	globals.PlayerGold -= 1
	GoldLabel.text = "Gold: " + str(gold)
	PlayerGoldLabel.text = "Player Gold: " + str(globals.PlayerGold)
	farmers -= 1
	FarmersLabel.text = "Farmers: " + str(farmers)
	globals.PlayerFarmers += 1
	PlayerFarmersLabel.text = "Player Farmers: " + str(globals.PlayerFarmers)

func _on_buy_thrall_pressed():
	gold += 1
	globals.PlayerGold -= 1
	GoldLabel.text = "Gold: " + str(gold)
	PlayerGoldLabel.text = " Player Gold: " + str(globals.PlayerGold)
	thralls -= 1
	ThrallsLabel.text = "Thralls: " + str(thralls)
	globals.PlayerThralls += 1
	PlayerThrallsLabel.text = "Player Thralls: " + str(globals.PlayerThralls)

func _on_sell_thrall_pressed():
	gold -= 1
	globals.PlayerGold += 1
	GoldLabel.text = "Gold: " + str(gold)
	PlayerGoldLabel.text = " Player Gold: " + str(globals.PlayerGold)
	thralls += 1
	ThrallsLabel.text = "Thralls: " + str(thralls)
	globals.PlayerThralls -= 1
	PlayerThrallsLabel.text = "Player Thralls: " + str(globals.PlayerThralls)

func _on_rumors_pressed():
	RumorsLabel.text = RumorDictionary[randi()%RumorDictionary.size()]
	RumorsLabel.visible = true
