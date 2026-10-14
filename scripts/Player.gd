extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 900.0

# Dash
@export var dash_speed: float = 700.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.4
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_direction: float = 1.0
var facing: float = 1.0


func _physics_process(delta: float) -> void:
	# Timers
	dash_cooldown_left = max(dash_cooldown_left - delta, 0.0)
	dash_time_left = max(dash_time_left - delta, 0.0)

	# Gravity
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Horizontal input
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing = direction

	# Start dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_left == 0.0:
		dash_time_left = dash_duration
		dash_cooldown_left = dash_cooldown
		dash_direction = direction if direction != 0.0 else facing

	# Apply movement
	if dash_time_left > 0.0:
		velocity.x = dash_direction * dash_speed
		velocity.y = 0.0  # optional: freeze vertical during dash
	else:
		if direction != 0.0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()
