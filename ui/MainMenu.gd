extends Node2D

@onready var play_button: Button = $UI/Center/VBox/PlayButton
@onready var level_select_button: Button = $UI/Center/VBox/LevelSelectButton
@onready var quit_button: Button = $UI/Center/VBox/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	# Start at level 1 (or whatever the player last played)
	GameState.current_level = 1
	get_tree().change_scene_to_file(GameState.get_level_path(1))


func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/LevelSelect.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
