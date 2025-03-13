extends CanvasLayer

# Node references
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

# Initial tavern resources
@onready var hides = 100
@onready var gold = 100
@onready var thralls = 100
@onready var farmers = 100
@onready var warriors = 100

# New tavern reputation mechanic
@onready var reputation = 50  # Range: 0–100, affects prices and rumors

# Resource types enum for clarity
enum ResourceType { HIDES, GOLD, THRALLS, FARMERS, WARRIORS }

# Base prices for resources (modified by reputation)
var resource_prices = {
    ResourceType.HIDES: 10,
    ResourceType.THRALLS: 20,
    ResourceType.FARMERS: 15,
    ResourceType.WARRIORS: 25
}

# Expanded rumor dictionary
@export var RumorDictionary = {
    0: "You hear that Lord Tom Hoppenstance is blessing his dragon-slaying sword at the temple.",
    1: "Rumors swirl of a treasure hidden in the local catacombs.",
    2: "The woods are haunted by an old hag tending her ghostly goats.",
    3: "The tannery’s stench is driving folks mad.",
    4: "A merchant’s strange seed grew a meat-scented beanstalk.",
    5: "A man chased his wife with a frying pan last night.",
    6: "A fool with a chicken on his head claims he’s king of the world.",
    7: "The mayor strutted about with a feather in his breeches.",
    8: "A barrel-clad beggar seeks coins for a ‘noble cause.’",
    9: "A half-orc ran through town with a pig atop his head.",
    10: "Lord John parades with a two-headed chicken on his shoulder.",
    11: "The butcher’s chicken is fouler than his temper.",
    12: "A man whispers to a cloth puppet in the streets.",
    13: "A wild-eyed prophet warns of a zombie invasion.",
    14: "The fortune teller predicts the King’s death by a green-clad assassin.",
    15: "A cloaked figure lingers near the tavern after dark.",
    16: "The blacksmith hammers away at a blade of legend.",
    17: "Adventurers plot a trek to the mountains.",
    18: "The tavern keeper’s hiding a fortune, they say.",
    19: "A beast prowls the forest, or so the drunks claim."
}

# Timer for periodic rumors
var rumor_timer = 0.0
const RUMOR_INTERVAL = 10.0  # Seconds between auto-rumors

func _ready():
    RumorsLabel.visible = false
    _update_all_labels()
    
    # Add tooltips for clarity
    $BuyHideButton.tooltip_text = "Buy 1 hide for gold."
    $SellHideButton.tooltip_text = "Sell 1 hide for gold."
    $RecruitWarriorButton.tooltip_text = "Hire a warrior for your party."
    $RecruitFarmerButton.tooltip_text = "Hire a farmer for your lands."
    $BuyThrallButton.tooltip_text = "Purchase a thrall."
    $SellThrallButton.tooltip_text = "Sell a thrall."
    $RumorsButton.tooltip_text = "Hear the latest tavern gossip."

func _process(delta):
    # Periodic rumor updates
    rumor_timer += delta
    if rumor_timer >= RUMOR_INTERVAL:
        _on_rumors_pressed()
        rumor_timer = 0.0

# Exit the tavern
func _on_exit_button_pressed():
    globals.player_position.x -= 100
    get_tree().change_scene_to_file("res://scenes/world.tscn")

# Button actions
func _on_buy_hide_pressed():
    _update_resource(ResourceType.HIDES, 1, true)
    _adjust_reputation(1)  # Buying helps the tavern

func _on_sell_hide_pressed():
    _update_resource(ResourceType.HIDES, 1, false)
    _adjust_reputation(-1)  # Selling slightly harms reputation

func _on_recruit_warrior_pressed():
    _update_resource(ResourceType.WARRIORS, 1, true)
    _adjust_reputation(2)  # Recruiting warriors boosts reputation

func _on_recruit_farmer_pressed():
    _update_resource(ResourceType.FARMERS, 1, true)
    _adjust_reputation(2)

func _on_buy_thrall_pressed():
    _update_resource(ResourceType.THRALLS, 1, true)
    _adjust_reputation(1)

func _on_sell_thrall_pressed():
    _update_resource(ResourceType.THRALLS, 1, false)
    _adjust_reputation(-1)

func _on_rumors_pressed():
    RumorsLabel.text = RumorDictionary[randi() % RumorDictionary.size()]
    RumorsLabel.visible = true

# Unified resource transaction function
func _update_resource(resource_type: ResourceType, amount: int, is_buy: bool) -> void:
    var resource_label: Label
    var player_resource_label: Label
    var resource_value: int
    var player_resource_value: int
    
    # Assign labels and values based on resource type
    match resource_type:
        ResourceType.HIDES:
            resource_label = HidesLabel
            player_resource_label = PlayerHidesLabel
            resource_value = hides
            player_resource_value = globals.PlayerHides
        ResourceType.THRALLS:
            resource_label = ThrallsLabel
            player_resource_label = PlayerThrallsLabel
            resource_value = thralls
            player_resource_value = globals.PlayerThralls
        ResourceType.FARMERS:
            resource_label = FarmersLabel
            player_resource_label = PlayerFarmersLabel
            resource_value = farmers
            player_resource_value = globals.PlayerFarmers
        ResourceType.WARRIORS:
            resource_label = WarriorsLabel
            player_resource_label = PlayerWarriorsLabel
            resource_value = warriors
            player_resource_value = globals.PlayerWarriors
    
    # Calculate price based on reputation (lower reputation = higher prices)
    var base_price = resource_prices.get(resource_type, 0)
    var price_modifier = 1.0 + (50 - reputation) * 0.01  # ±50% price swing
    var price = int(base_price * price_modifier) * amount
    
    if is_buy:
        if globals.PlayerGold >= price and resource_value >= amount:
            globals.PlayerGold -= price
            gold += price
            resource_value -= amount
            player_resource_value += amount
        else:
            _notify_player("Not enough gold or tavern stock!")
            return
    else:
        if player_resource_value >= amount:
            globals.PlayerGold += price
            gold -= price
            resource_value += amount
            player_resource_value -= amount
        else:
            _notify_player("Not enough resources to sell!")
            return
    
    # Update tavern resources
    match resource_type:
        ResourceType.HIDES:
            hides = resource_value
            globals.PlayerHides = player_resource_value
        ResourceType.THRALLS:
            thralls = resource_value
            globals.PlayerThralls = player_resource_value
        ResourceType.FARMERS:
            farmers = resource_value
            globals.PlayerFarmers = player_resource_value
        ResourceType.WARRIORS:
            warriors = resource_value
            globals.PlayerWarriors = player_resource_value
    
    _update_all_labels()

# Update all resource labels
func _update_all_labels():
    HidesLabel.text = "Hides: " + str(hides)
    ThrallsLabel.text = "Thralls: " + str(thralls)
    FarmersLabel.text = "Farmers: " + str(farmers)
    WarriorsLabel.text = "Warriors: " + str(warriors)
    GoldLabel.text = "Gold: " + str(gold)
    PlayerHidesLabel.text = "Player Hides: " + str(globals.PlayerHides)
    PlayerThrallsLabel.text = "Player Thralls: " + str(globals.PlayerThralls)
    PlayerFarmersLabel.text = "Player Farmers: " + str(globals.PlayerFarmers)
    PlayerWarriorsLabel.text = "Player Warriors: " + str(globals.PlayerWarriors)
    PlayerGoldLabel.text = "Player Gold: " + str(globals.PlayerGold)

# Adjust tavern reputation
func _adjust_reputation(change: int):
    reputation = clamp(reputation + change, 0, 100)
    # Optionally display reputation to the player in a UI element

# Simple notification system (assumes a Label node named Notification exists)
func _notify_player(message: String):
    # Placeholder: In a real game, use a proper UI popup or timer
    print(message)
    # Example: $Notification.text = message; $Notification.visible = true
