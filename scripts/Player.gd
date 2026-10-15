extends CharacterBody2D

# --- Movement ---
@export var speed: float = 300.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1600.0
@export var max_fall_speed: float = 1200.0

# --- Dash ---
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.4
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_direction: float = 1.0
var facing: float = 1.0

# --- Grapple ---
@export var grapple_max_distance: float = 700.0
@export var grapple_swing_force: float = 2600.0
@export var grapple_reel_speed: float = 260.0
@export var grapple_min_length: float = 40.0
@export var grapple_min_distance: float = 16.0
@export var grapple_max_speed: float = 1800.0

var is_grappling: bool = false
var is_aiming: bool = false
var grapple_point: Vector2 = Vector2.ZERO
var rope_length: float = 0.0

@onready var rope: Line2D = $Rope


func _physics_process(delta: float) -> void:
	# Timers
	dash_cooldown_left = max(dash_cooldown_left - delta, 0.0)
	dash_time_left = max(dash_time_left - delta, 0.0)

	# Gravity — always on unless we're on the floor
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Input
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing = direction

	# Start dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_left == 0.0:
		dash_time_left = dash_duration
		dash_cooldown_left = dash_cooldown
		dash_direction = direction if direction != 0.0 else facing

	# --- Movement ---
	if dash_time_left > 0.0:
		velocity.x = dash_direction * dash_speed
		velocity.y = 0.0
	elif is_grappling:
		var to_anchor: Vector2 = grapple_point - global_position
		var dist: float = to_anchor.length()
		if dist > 0.001:
			var radial: Vector2 = to_anchor / dist
			var tangent: Vector2 = Vector2(-radial.y, radial.x)
			if direction != 0.0:
				velocity += tangent * direction * grapple_swing_force * delta
	else:
		if direction != 0.0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# Clamp speed
	var max_speed_now: float = grapple_max_speed if is_grappling else max_fall_speed
	velocity = velocity.limit_length(max_speed_now)

	move_and_slide()

	# --- Rope constraint ---
	if is_grappling:
		var to_anchor: Vector2 = grapple_point - global_position
		var dist: float = to_anchor.length()
		if dist > 0.001:
			var radial: Vector2 = to_anchor / dist

			# Reel in
			rope_length = max(rope_length - grapple_reel_speed * delta, grapple_min_length)

			# Auto-release when reeled all the way in
			if rope_length <= grapple_min_length + 1.0:
				is_grappling = false
				return

			# Snap position to circle
			global_position = grapple_point - radial * rope_length

			# Kill radial velocity, keep tangential
			var radial_speed: float = velocity.dot(radial)
			velocity -= radial * radial_speed

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # Esc by default
		get_tree().change_scene_to_file("res://ui/LevelSelect.tscn")
	# ... keep your existing grapple input here

func _process(_delta: float) -> void:
	if is_grappling:
		rope.visible = true
		rope.modulate = Color(1, 1, 1, 1)
		rope.points = PackedVector2Array([
			Vector2.ZERO,
			to_local(grapple_point)
		])
	elif is_aiming:
		# Visual feedback: rope follows the mouse even without a hit
		rope.visible = true
		rope.modulate = Color(1, 1, 1, 0.35)
		rope.points = PackedVector2Array([
			Vector2.ZERO,
			to_local(get_global_mouse_position())
		])
	else:
		rope.visible = false
		rope.modulate = Color(1, 1, 1, 1)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			try_grapple()
		else:
			release_grapple()


func try_grapple() -> void:
	is_aiming = true

	var mouse_pos: Vector2 = get_global_mouse_position()
	var origin: Vector2 = global_position
	var to_mouse: Vector2 = mouse_pos - origin

	if to_mouse.length() < 4.0:
		return

	var distance: float = min(to_mouse.length(), grapple_max_distance)
	var dir: Vector2 = to_mouse.normalized()

	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		origin,
		origin + dir * distance
	)
	query.exclude = [self]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := space.intersect_ray(query)
	print("ray hit: ", result)  # debug — remove later

	if result.is_empty():
		return

	var hit: Vector2 = result.position
	if hit.distance_to(origin) < grapple_min_distance:
		return

	grapple_point = hit
	rope_length = origin.distance_to(hit)
	is_grappling = true


func release_grapple() -> void:
	is_aiming = false
	is_grappling = false
	grapple_point = Vector2.ZERO
