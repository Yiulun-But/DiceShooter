extends CharacterBody2D

const SPEED := 180.0
const JUMP_FORCE := -700.0
var gravity_vec: Vector2 = Vector2.DOWN * 1580.0  # current gravity vector
var grav_direction = Vector2.DOWN
var grav_on = false

	
func _physics_process(delta: float) -> void:
	# Apply gravity when not grounded
	if not is_on_floor() and grav_on:
			velocity += gravity_vec * delta
	else:
		# Optional: stick to floor / reset vertical speed
		if velocity.y > 0.0:
			velocity.y = 0.0

	if not grav_on:
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		velocity = input_dir.normalized() * SPEED + Vector2(randi_range(-60, 60), randi_range(-30, 30))
	# Horizontal input (A/D or Left/Right)
	var dir := Input.get_axis("ui_left", "ui_right")
	if dir != 0.0:
		velocity.x = dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Jump (Space by default if "ui_accept" is mapped)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = grav_direction.y * JUMP_FORCE

	move_and_slide()

func set_gravity_direction(new_dir: Vector2, strength: float = 980.0):
	gravity_vec = new_dir.normalized() * strength
	up_direction = -new_dir.normalized()   # IMPORTANT: opposite of gravity

func _on_timer_timeout() -> void:
	grav_direction = directions.pick_random()
	if grav_direction == Vector2.ZERO:
		grav_on = false
	else:
		grav_on = true		
		set_gravity_direction(grav_direction)
		translate(gravity_vec.normalized() * 0.1)

var directions = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.ZERO
]
