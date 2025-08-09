extends Node3D

const level = [
	1, 1, 1, 1, 5, 5, 5, 5, 
	5, 5, 5, 5, 5, 5, 5, 5,
	5, 2, 5, 2, 5, 2, 5, 2,
	5, 2, 5, 2, 5, 2, 5, 2,
	6, 2, 6, 2, 6, 2, 6, 2,
	6, 2, 6, 2, 6, 2, 6, 2,
	6, 2, 6, 2, 6, 2, 6, 2,
	6, 2, 6, 2, 6, 2, 6, 2,
]
const die_spacing = 1.2
@onready var dice = preload("res://die.tscn")

var bgm
var target_pos = position

func _ready():
	add_to_group("levelgen")
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	
	var prev_die = null
	for i in range(len(level)):
		var die = dice.instantiate()
		
		if prev_die != null: prev_die.next = die
		
		die.spawn_face = level[i]
		bgm.connect("on_beat", Callable(die, "_on_beat"))
		add_child(die)
		
		die.global_position = Vector3(die_spacing * i, 0, 0)
		if i == 0: die.active = true
		
		prev_die = die

func _process(_delta):
	position = lerp(position, target_pos, .1)
