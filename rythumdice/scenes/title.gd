extends Node3D

@onready var cyan: SpotLight3D = get_node("Scene/Stage/Spotlight/Cyan")
@onready var white: SpotLight3D = get_node("Scene/Stage/Spotlight/White")
@onready var orange: SpotLight3D = get_node("Scene/Stage/Spotlight/Orange")
@onready var die: Node3D = get_node("Scene/die")
@onready var timer: Timer = get_node("Timer")

var spotlights: Array[SpotLight3D]
var current_light_index: int = 0

func _ready() -> void:
	# Aim all spotlights at the die
	cyan.look_at(die.global_position)
	white.look_at(die.global_position)
	orange.look_at(die.global_position)
	
	# Setup spotlight array for cycling
	spotlights = [white, cyan, orange]  # Start with white
	
	# Turn off all lights initially
	turn_off_all_lights()
	
	# Start with white spotlight
	spotlights[current_light_index].visible = true
	
	# Setup and start timer
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	await get_tree().create_timer(1.0).timeout
	timer.start()

func turn_off_all_lights():
	cyan.visible = false
	white.visible = false
	orange.visible = false

func _on_timer_timeout():
	# Turn off current light
	spotlights[current_light_index].visible = false
	
	# Move to next light
	current_light_index = (current_light_index + 1) % spotlights.size()
	
	# Turn on next light
	spotlights[current_light_index].visible = true

# Optional: Functions to control the alternating
func start_alternating():
	timer.start()

func stop_alternating():
	timer.stop()

func pause_alternating():
	timer.paused = true

func resume_alternating():
	timer.paused = false
