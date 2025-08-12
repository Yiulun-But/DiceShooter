extends Node3D

var bgm
var level_data

const SCORE_PER_BEAT = 60
const SCORE_PER_BEAT_BONUS = 20
# score
var score

@onready var score_ingame: Label3D = $ScoreIngame
@onready var score_background: MeshInstance3D = $MeshInstance3D
@onready var score_final: Label3D = $MeshInstance3D/ScoreFinal
@onready var score_gained = preload("res://scenes/score_gained.tscn")

func _ready() -> void:
	# initialize the score
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	score = 0
	
	# load level data
	level_data = get_tree().get_nodes_in_group("levelgen")[0].level_data
	
	# connect signals from all dices
	for e in get_tree().get_nodes_in_group("dices"):
		e.dice_finished.connect(_on_dice_finished)
	# connect level finish signal for last dice
	get_tree().get_nodes_in_group("dices")[-1].level_finished.connect(_on_level_finished)
	
	# initialize score display
	score_ingame.text = "0"

func _process(_delta: float) -> void:
	score_ingame.text = str(score)
	
func _on_dice_finished(moves: int, facing: bool):
	if facing:
		add_score(moves)

func add_score(moves: int):
	score += SCORE_PER_BEAT
	
	# apply effect
	var score_gained_inst = score_gained.instantiate()
	score_gained_inst.global_transform.origin = Vector3(0, 2, 0)
	score_gained_inst.set_score_text(SCORE_PER_BEAT)
	add_child(score_gained_inst)
	
	if (moves <= 1):
		score += SCORE_PER_BEAT_BONUS

func _on_level_finished():
	score_background.visible = true
	score_final.text = str(score)
