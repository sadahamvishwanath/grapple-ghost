extends Node

# Levels are 1..5 for now. Add more later.
const TOTAL_LEVELS: int = 5

# Highest level number the player has reached. Starts at 1.
var highest_unlocked: int = 1

# Which level the player is currently in.
var current_level: int = 1

# Best time per level, in seconds. 0.0 means no run yet.
var best_times: Dictionary = {}

# Paths to each level scene.
const LEVEL_PATHS: Array[String] = [
	"res://levels/Level1.tscn",
	"res://levels/Level2.tscn",
	"res://levels/Level3.tscn",
	"res://levels/Level4.tscn",
	"res://levels/Level5.tscn",
]


func unlock_next_level(from_level: int) -> void:
	var next: int = from_level + 1
	if next > highest_unlocked and next <= TOTAL_LEVELS:
		highest_unlocked = next


func get_level_path(level_number: int) -> String:
	if level_number < 1 or level_number > LEVEL_PATHS.size():
		return ""
	return LEVEL_PATHS[level_number - 1]
