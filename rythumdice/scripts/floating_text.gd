extends Label3D

@export var fade_in_time: float = 0.3     # seconds to fade in
@export var visible_time: float = 1.0     # seconds to stay fully visible
@export var fade_out_time: float = 0.3    # seconds to fade out
@export var start_color: Color = Color.WHITE  # initial text color (without alpha)

func _ready():
	# Start invisible
	var c = start_color
	c.a = 0.0
	modulate = c

	# Tween sequence
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_time) # fade in
	tween.tween_interval(visible_time)                          # wait
	tween.tween_property(self, "modulate:a", 0.0, fade_out_time) # fade out
	tween.tween_callback(queue_free)                            # delete after
	
func set_time_out(t: float):
	visible_time = t

func set_text_and_colour(txt: String, color: Color):
	text = txt
	start_color = color
