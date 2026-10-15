extends Node2D

var frames: Array = []
var index: int = 0
var playing: bool = false


func setup(ghost_frames: Array) -> void:
	frames = ghost_frames
	index = 0
	playing = frames.size() > 0
	print("[Ghost] setup: frames=", frames.size(), " playing=", playing)
	if playing:
		global_position = frames[0]


func _physics_process(_delta: float) -> void:
	if not playing:
		return
	if index >= frames.size():
		playing = false
		return
	global_position = frames[index]
	index += 1
