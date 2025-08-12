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
@onready var button: Label3D = $MeshInstance3D/ButtonToTheMenu
@onready var button_area: Area3D = $MeshInstance3D/Area3D


func _ready() -> void:
	# initialize the score
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	score = 0
	
	# initialize button
	
	button_area.mouse_entered.connect(_hover_on)
	button_area.mouse_exited.connect(_hover_off)
	button_area.input_event.connect(_on_area_input)
	
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
	
func _on_dice_finished(best_moves: bool, right_facing: bool):
	if not right_facing: return
	
	score += SCORE_PER_BEAT
	
	# apply effect
	var score_gained_inst = score_gained.instantiate()
	score_gained_inst.position = Vector3(0, 0.2, 0)
	
	if (best_moves):
		# perfect
		score += SCORE_PER_BEAT_BONUS
		score_gained_inst.set_score_colour(Color("#d48142"))
		score_gained_inst.set_score_text("PERFECT")
	else:
		# good
		score_gained_inst.set_score_colour(Color("#613228"))
		score_gained_inst.set_score_text("GOOD")
	
	add_child(score_gained_inst)

func _on_level_finished():
	score_background.visible = true
	score_final.text = str(score)

# events for button
func _hover_on() -> void:
	# simple hover feedback
	button.modulate = Color(1, 1, 1, 1)         # bright
func _hover_off() -> void:
	button.modulate = Color(0.85, 0.85, 0.85)   # dim

func _on_area_input(camera, event, position, normal, shape_idx) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_button_pressed()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	
