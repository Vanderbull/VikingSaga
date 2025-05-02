extends Control

signal textbox_closed

@export var enemy:Resource = null

var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

func _ready():
	set_health($EnemyContainer/ProgressBar,enemy.health,enemy.health)
	set_health($PlayerPanel/MarginContainer/PlayerData/ProgressBar,State.current_health,State.max_health)
	$EnemyContainer/Enemy.texture = enemy.texture
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	$MarginTextbox.hide()
	$ActionsPanel.hide()
	display_text("a wild %s appears!" % enemy.name.to_upper())
	await textbox_closed
	$ActionsPanel.show()

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP:%d/%d" % [health,max_health]
	
func _input(event):
	if(Input.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		$MarginTextbox.hide()
		emit_signal("textbox_closed")
		
func display_text(text):
	$MarginTextbox.show()
	$MarginTextbox/Textbox/Label.text = text
	
func enemy_turn():
	display_text("%s launches at you" % enemy.name)
	await textbox_closed
	if is_defending:
		is_defending = false
		display_text("you blocked the attack like a king")
		await textbox_closed
	else:
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/MarginContainer/PlayerData/ProgressBar,current_player_health,State.max_health)
	$ActionsPanel.show()

func _on_run_pressed():
	display_text("you run away like a coward")
	await textbox_closed
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_attack_pressed():
	display_text("you swing your cute paws")
	await textbox_closed
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/ProgressBar,current_enemy_health,enemy.health)
	if current_enemy_health == 0:
		display_text("%s was defeated" % enemy.name)
		await textbox_closed
		get_tree().change_scene_to_file("res://scenes/game/game.tscn")
	enemy_turn()

func _on_defend_pressed():
	is_defending = true
	display_text("you prepare to block the imcoming attack")
	await textbox_closed
	enemy_turn()
