extends Node3D

@onready var bpm_timer = $bpm_timer
var target_scale  = 3.5
var current_scale = 3.5

func _ready():
	bpm_timer.wait_time = 60. / (180.) # menu is 180 bpm
	bpm_timer.start()

func _process(_delta):
	current_scale = lerp(current_scale, target_scale, .1)
	scale = Vector3.ONE * current_scale

func _on_beat_menu() -> void:
	current_scale = 3.6
