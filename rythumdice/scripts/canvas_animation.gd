extends Control

@onready var title = $Title
@onready var buttons = [$Play/VBoxContainer/Easy, $Play/VBoxContainer/Medium, $Play/VBoxContainer/Hard]

var slide_distance: float = 300.0
var animation_duration: float = 0.7
var stagger_delay: float = 0.15

func _ready():
	setup_advanced_animation()

func setup_advanced_animation():
	# Store original positions
	var original_positions = []
	for button in buttons:
		original_positions.append(button.position)
	
	# Setup initial states
	title.modulate.a = 0.0
	title.scale = Vector2(0.8, 0.8)  # Start smaller
	
	for button in buttons:
		button.position.x += slide_distance
		button.modulate.a = 0.0  # Also fade in
	
	# Animate title with scale + fade
	var title_tween = create_tween()
	title_tween.set_parallel(true)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.8)
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.set_trans(Tween.TRANS_ELASTIC)
	
	# Wait then animate buttons
	await get_tree().create_timer(0.4).timeout
	
	for i in range(buttons.size()):
		animate_button_advanced(buttons[i], original_positions[i], i)

func animate_button_advanced(button: Button, target_pos: Vector2, index: int):
	await get_tree().create_timer(stagger_delay * index).timeout
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Slide up
	tween.tween_property(button, "position", target_pos, animation_duration)
	# Fade in
	tween.tween_property(button, "modulate:a", 1.0, animation_duration * 0.8)
