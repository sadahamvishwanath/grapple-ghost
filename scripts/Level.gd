extends Node2D

@export var level_number: int = 1

@onready var player: CharacterBody2D = $Player
@onready var exit: Area2D = $Exit
@onready var hud: CanvasLayer = $LevelHUD

var finished: bool = false

# Recording
var recording: Array[Vector2] = []
var recording_active: bool = false

const GHOST_SCENE := preload("res://scenes/Ghost.tscn")


func _ready() -> void:
	# Setup HUD
	var best: float = GameState.best_times.get(level_number, 0.0)
	hud.show_best(best)

	# Hook up exit
	exit.reached.connect(_on_exit_reached)

	# Reset player to spawn
	player.global_position = $SpawnPoint.global_position

	# Start recording
	recording.clear()
	recording_active = true

	# Spawn ghost if there is one
	var ghost_frames: Array = GameState.get_ghost(level_number)
	print("[Level] _ready: ghost_frames.size()=", ghost_frames.size())
	if ghost_frames.size() > 0:
		var ghost := GHOST_SCENE.instantiate()
		add_child(ghost)
		ghost.setup(ghost_frames)
		print("[Level] ghost spawned at ", ghost.global_position)
	else:
		print("[Level] no ghost to spawn")


func _physics_process(_delta: float) -> void:
	if recording_active:
		recording.append(player.global_position)

	if Input.is_action_just_pressed("restart"):
		_restart_level()


func _on_exit_reached() -> void:
	if finished:
		return
	finished = true
	recording_active = false
	hud.stop()

	var time: float = hud.time

	var prev_best: float = GameState.best_times.get(level_number, 0.0)
	var is_new_best: bool = prev_best <= 0.0 or time < prev_best

	if is_new_best:
		print("[Level] new best! frames recorded = ", recording.size())
		GameState.best_times[level_number] = time
		GameState.save_ghost(level_number, recording)
		print("[Level] New best time: ", time)
	else:
		print("[Level] not a new best. prev=", prev_best, " current=", time)

	GameState.unlock_next_level(level_number)

	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://ui/LevelSelect.tscn")


func _restart_level() -> void:
	get_tree().reload_current_scene()
