extends Node3D

@onready var score = preload("res://scenes/score.tscn")

func _ready():
	# generate score display
	var score_inst = score.instantiate()
	add_child(score_inst)
	score_inst.global_transform.origin = Vector3(-3, 0, -2)
