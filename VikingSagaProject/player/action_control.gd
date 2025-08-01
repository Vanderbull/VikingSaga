extends Control
@onready var globals = get_node("/root/Globals")
@onready var progress_bar = $ProgressBar
var step := 20  # How much to increase each click

func _ready() -> void:
	progress_bar.hide()
	
func _on_dig_pressed() -> void:
	progress_bar.show()
	#position = globals.character_position
	#progress_bar.position = position
	
	progress_bar.visible = true  # Make sure it's visible
	# Increase the progress bar value by 10, with a max of 100
	#progress_bar.value = clamp(progress_bar.value + 10, progress_bar.min_value, progress_bar.max_value)
	var new_value = progress_bar.value + step
	var is_reset = false
	if new_value > progress_bar.max_value:
		new_value = 0
		is_reset = true

	var tween = create_tween()
	tween.tween_property(
		progress_bar,
		"value",
		new_value,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	#if tween.finished:
		#progress_bar.visible = false  # Hide the ProgressBar
	#else:
		#progress_bar.visible = true  # Hide the ProgressBar
	
	if is_reset:
		# Wait until tween finishes, then call a method
		tween.tween_callback(Callable(self, "_on_progress_reset"))
	else:
		tween.tween_callback(Callable(self, "_on_progress_updated"))
		#update_labels(new_value)

func _on_progress_reset():
	update_labels(0)
	progress_bar.visible = false  # Hide the ProgressBar

func _on_progress_updated():
	update_labels(progress_bar.value)
	
func update_labels(value: int):
	var _my_tile_type = globals.TerrainType.GRASS
	#print(globals.TerrainType.keys()[my_tile_type])  # Outputs "FOREST"
	for label in get_tree().get_nodes_in_group("updatable_labels"):
		if label.name == "QuestWater" and globals.Terrain == "Water":
			globals.quest_water += value
			if globals.quest_water >= globals.MAX_QUEST_WATER:
				label.text = "[✓] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
			else:
				label.text = "[ ] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
		if label.name == "QuestTrees" and globals.Terrain == "Forest":
			globals.quest_wood += value
			if globals.quest_wood >= globals.MAX_QUEST_WOOD:
				label.text = "[✓] Collect trees %s / %d" % [globals.quest_wood, globals.MAX_QUEST_WOOD]
			else:
				label.text = "[ ] Collect trees %s / %d" % [globals.quest_wood, globals.MAX_QUEST_WOOD]
		if label.name == "QuestClay" and globals.Terrain == "Grass":
			globals.quest_clay += value
			if globals.quest_clay >= globals.MAX_QUEST_CLAY:
				label.text = "[✓] Collect clay %s / %d" % [globals.quest_clay, globals.MAX_QUEST_CLAY]
			else:
				label.text = "[ ] Collect clay %s / %d" % [globals.quest_clay, globals.MAX_QUEST_CLAY]
func _on_collect_water_pressed() -> void:
	progress_bar.show()
	# Increase the progress bar value by 10, with a max of 100
	#progress_bar.value = clamp(progress_bar.value + 10, progress_bar.min_value, progress_bar.max_value)
	var new_value = progress_bar.value + step
	var is_reset = false
	if new_value > progress_bar.max_value:
		new_value = 0
		is_reset = true

	var tween = create_tween()
	tween.tween_property(
		progress_bar,
		"value",
		new_value,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	#if tween.finished:
		#progress_bar.visible = false  # Hide the ProgressBar
	#else:
		#progress_bar.visible = true  # Hide the ProgressBar
	if is_reset:
		# Wait until tween finishes, then call a method
		tween.tween_callback(Callable(self, "_on_progress_reset"))
	else:
		tween.tween_callback(Callable(self, "_on_progress_updated"))
		update_labels(new_value)
