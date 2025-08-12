extends Label3D

@export var float_distance: float = 1.0  # How high it moves
@export var duration: float = 0.5        # How long until it disappears
@export var score_color: Color = Color.WHITE

var start_position: Vector3
var time_passed: float = 0.0

func _ready():
	start_position = global_transform.origin
	modulate = score_color

func set_score_text(points: int):
	text = "+" + str(points)

func _process(delta: float):
	time_passed += delta
	var t = time_passed / duration

	# Move upward
	global_transform.origin = start_position + Vector3(0, t * float_distance, 0)

	# Fade out
	var fade_color = modulate
	fade_color.a = 1.0 - t
	modulate = fade_color

	# Delete when finished
	if time_passed >= duration:
		queue_free()
