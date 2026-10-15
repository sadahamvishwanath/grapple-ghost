extends Node

const TOTAL_LEVELS: int = 5
const SAVE_PATH: String = "user://save.json"

var highest_unlocked: int = 1
var current_level: int = 1
var best_times: Dictionary = {}
var ghosts: Dictionary = {}

const LEVEL_PATHS: Array[String] = [
	"res://levels/Level1.tscn",
	"res://levels/Level2.tscn",
	"res://levels/Level3.tscn",
	"res://levels/Level4.tscn",
	"res://levels/Level5.tscn",
]


	
func _ready() -> void:
	load_game()
	print("[GameState] _ready fired")
	load_game()
	
func unlock_next_level(from_level: int) -> void:
	var next: int = from_level + 1
	if next > highest_unlocked and next <= TOTAL_LEVELS:
		highest_unlocked = next
		save_game()


func get_level_path(level_number: int) -> String:
	if level_number < 1 or level_number > LEVEL_PATHS.size():
		return ""
	return LEVEL_PATHS[level_number - 1]


func save_ghost(level_number: int, frames: Array) -> void:
	ghosts[level_number] = frames.duplicate()
	print("[GameState] save_ghost level=", level_number, " frames=", ghosts[level_number].size())
	save_game()


func get_ghost(level_number: int) -> Array:
	var g: Array = ghosts.get(level_number, [])
	print("[GameState] get_ghost level=", level_number, " frames=", g.size())
	return g


# --- Persistence ---

func save_game() -> void:
	var data: Dictionary = {
		"highest_unlocked": highest_unlocked,
		"best_times": _dict_int_float(best_times),
		"ghosts": _serialize_ghosts(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: " + SAVE_PATH)
		return
	file.store_string(JSON.stringify(data))
	file.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading: " + SAVE_PATH)
		return
	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Save file is corrupted.")
		return

	highest_unlocked = int(parsed.get("highest_unlocked", 1))

	best_times.clear()
	var bt: Dictionary = parsed.get("best_times", {})
	for key in bt.keys():
		best_times[int(key)] = float(bt[key])

	ghosts.clear()
	var gs: Dictionary = parsed.get("ghosts", {})
	for key in gs.keys():
		var arr: Array = gs[key]
		var frames: Array[Vector2] = []
		for item in arr:
			frames.append(Vector2(float(item[0]), float(item[1])))
		ghosts[int(key)] = frames

	print("[GameState] loaded save. levels unlocked=", highest_unlocked,
		  " best_times=", best_times.size(), " ghosts=", ghosts.size())


# --- Helpers for JSON-safe conversion ---

func _dict_int_float(d: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in d.keys():
		out[str(k)] = float(d[k])
	return out


func _serialize_ghosts() -> Dictionary:
	var out: Dictionary = {}
	for level in ghosts.keys():
		var frames: Array = ghosts[level]
		var packed: Array = []
		for v in frames:
			packed.append([v.x, v.y])
		out[str(level)] = packed
	return out

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	highest_unlocked = 1
	best_times.clear()
	ghosts.clear()
	print("[GameState] save reset")
