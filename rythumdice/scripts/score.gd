extends Node3D

var bgm
var level_data
 
const SCORING_FACING = 6
# score
var score
var score_per_beat

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
	
	# initialize score data
	score_per_beat = 100. / bgm.timings.size()
	
	# initialize score display
	label.text = "0 %"
		
		

func _process(_delta: float) -> void:
	label.text = "%0.2f" % score + " %"
	
func _on_dice_finished(moves: int, facing: int):
	if facing == SCORING_FACING:
		add_score(moves)
	print("moves: ", moves, ", facing: ", facing)

func add_score(moves: int):
	score += score_per_beat
	if (moves <= 1):
		score += score_per_beat * 0.01
