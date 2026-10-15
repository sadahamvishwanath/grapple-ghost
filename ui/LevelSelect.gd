extends Node2D

@onready var grid: GridContainer = $UI/Margin/VBox/Grid
@onready var back_button: Button = $UI/Margin/VBox/BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_build_level_buttons()


func _build_level_buttons() -> void:
	for i in range(1, GameState.TOTAL_LEVELS + 1):
		var btn := Button.new()
		btn.text = "Level %d" % i
		btn.custom_minimum_size = Vector2(160, 60)
		btn.disabled = i > GameState.highest_unlocked
		btn.pressed.connect(_on_level_button_pressed.bind(i))
		grid.add_child(btn)


func _on_level_button_pressed(level_number: int) -> void:
	GameState.current_level = level_number
	var path := GameState.get_level_path(level_number)
	if path != "":
		get_tree().change_scene_to_file(path)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
