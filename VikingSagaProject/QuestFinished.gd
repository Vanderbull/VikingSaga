extends Control
class_name QuestFinished

signal quest_continued

@export var fade_duration: float = 0.5
@export var quest_name: String = "Unnamed Quest"

@onready var title_label = $Panel/VBoxContainer/Title
@onready var desc_label = $Panel/VBoxContainer/Description
@onready var audio_player = $AudioStreamPlayer

func _ready():
    # Update UI with quest information
    title_label.text = "%s Completed!" % quest_name
    desc_label.text = "Congratulations on finishing %s!" % quest_name
    
    # Fade in animation
    modulate.a = 0.0
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 1.0, fade_duration).set_ease(Tween.EASE_IN_OUT)

func _on_button_pressed():
    # Fade out animation before continuing
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, fade_duration).set_ease(Tween.EASE_IN_OUT)
    tween.tween_callback(_emit_continue_signal)
    
    if audio_player:
        audio_player.stop()

func _emit_continue_signal():
    quest_continued.emit()
    queue_free()

func set_quest_info(name: String, description: String = ""):
    quest_name = name
    if description:
        desc_label.text = description
    if is_node_ready():
        title_label.text = "%s Completed!" % quest_name
