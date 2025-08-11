extends Camera3D

@export var start_angle: float = -9.0    # Starting pitch angle (looking down)
@export var end_angle: float = 5.8       # Ending pitch angle (looking slightly up)
@export var wait_time: float = 1.0       # Time to wait before starting animation
@export var animation_duration: float = 2.5  # Time for the rise animation
@export var easing_type: Tween.EaseType = Tween.EASE_OUT
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC

var animation_tween: Tween
var has_animated: bool = false

func _ready():
	# Set initial camera angle
	rotation_degrees.x = start_angle
	current = true
	
	# Start the animation sequence
	start_intro_animation()

func start_intro_animation():
	if has_animated:
		return
		
	has_animated = true
	
	# Wait for a moment, then start the rise animation
	await get_tree().create_timer(wait_time).timeout
	animate_camera_rise()

func animate_camera_rise():
	# Create tween for smooth animation
	animation_tween = create_tween()
	animation_tween.set_ease(easing_type)
	animation_tween.set_trans(transition_type)
	
	# Animate the X rotation (pitch) from start_angle to end_angle
	animation_tween.tween_method(
		set_camera_pitch,
		start_angle,
		end_angle,
		animation_duration
	)
	
	# Optional: Add a subtle "settling" effect at the end
	animation_tween.tween_callback(on_animation_complete)

func set_camera_pitch(angle: float):
	rotation_degrees.x = angle

func on_animation_complete():
	# Animation finished - camera is now at final position
	print("Camera intro animation complete")
	
	# You can emit a signal here if other systems need to know
	# animation_finished.emit()

# Optional: Function to restart the animation (for testing)
func restart_animation():
	if animation_tween:
		animation_tween.kill()
	
	has_animated = false
	rotation_degrees.x = start_angle
	start_intro_animation()

# Optional: Function to skip to end position immediately
func skip_to_end():
	if animation_tween:
		animation_tween.kill()
	
	rotation_degrees.x = end_angle
	has_animated = true
