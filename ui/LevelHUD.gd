extends CanvasLayer

@onready var time_label: Label = $VBox/TimeLabel
@onready var best_label: Label = $VBox/BestLabel

var time: float = 0.0
var running: bool = true


func _process(delta: float) -> void:
	if running:
		time += delta
		time_label.text = "%.2f" % time


func stop() -> void:
	running = false


func reset() -> void:
	time = 0.0
	running = true
	time_label.text = "0.00"


func show_best(best: float) -> void:
	if best <= 0.0:
		best_label.text = "Best: --"
	else:
		best_label.text = "Best: %.2f" % best
