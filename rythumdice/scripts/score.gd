extends Node3D

var bgm
var level_data

const SEC_PER_MIN = 60
# percentage of one beat for timing 
const PERFECT_TIMING = 0.3
const GOOD_TIMING = 0.5
var perfect_timing
var good_timing
# score
const PERFECT_CONTRIBUTION = 1
const GOOD_CONTRIBUTION = 0.8
var score
var score_per_node

@onready var label: Label3D = $Label3D

func _ready() -> void:
	# initialize the score
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	score = 0
	score_per_node = 100. / bgm.timings.size()
	
	# load level data
	level_data = get_tree().get_nodes_in_group("levelgen")[0].level_data
	
	# calculate timing period
	perfect_timing = SEC_PER_MIN / level_data.bpm * PERFECT_TIMING
	good_timing = SEC_PER_MIN / level_data.bpm * GOOD_TIMING
	
	# initialize score display
	label.text = str(score) + "%"
	
# check and calculate the score when player pressed key
func check_score():
	if Input.is_action_just_pressed("up") \
	or Input.is_action_just_pressed("down") \
	or Input.is_action_just_pressed("left") \
	or Input.is_action_just_pressed("right"):
		var timing = calculate_accuracy_timing()
		if (timing <= perfect_timing):
			score += score_per_node * PERFECT_CONTRIBUTION
			print("PERFECT")
			return PERFECT_TIMING
		elif (timing <= good_timing):
			score += score_per_node * GOOD_CONTRIBUTION
			print("GOOD")
			return GOOD_TIMING
		else:
			return -1
		
# calculate time difference between current beat and perfect beat
func calculate_accuracy_timing():
	return abs(bgm.timings[bgm.next_beat - 1] \
		- bgm.song.get_playback_position())
		
func _process(_delta: float) -> void:
	check_score()
	label.text = str(score) + "%"
	
