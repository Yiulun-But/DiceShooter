extends Node3D

var bgm
var level_data

const SEC_PER_MIN = 60

# score
var score

@onready var label: Label3D = $Label3D

func _ready() -> void:
	# initialize the score
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	score = 0
	
	# load level data
	level_data = get_tree().get_nodes_in_group("levelgen")[0].level_data
	
	# connect signals from all dices
	for e in get_tree().get_nodes_in_group("dices"):
		e.dice_finished.connect(_on_dice_finished)
	
	# initialize score display
	label.text = str(score) + "%"
		
		
# calculate time difference between current beat and perfect beat
func calculate_accuracy_timing():
	return abs(bgm.timings[bgm.next_beat - 1] \
		- bgm.song.get_playback_position())
		

func _process(_delta: float) -> void:
	label.text = str(score) + "%"
	
func _on_dice_finished(moves: int, facing: int):
	print("moves: ", moves, ", facing: ", facing)
