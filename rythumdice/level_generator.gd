extends Node3D

const level = {
	"bpm": 120,
	"audio": "res://audio/basic_song.wav",
	"dice": [
		1, 1, 1, 1, 5, 5, 5, 5, 
		5, 5, 5, 5, 5, 5, 5, 5,
		5, 2, 5, 2, 5, 2, 5, 2,
		5, 2, 5, 2, 5, 2, 5, 2,
		6, 2, 6, 2, 6, 2, 6, 2,
		6, 2, 6, 2, 6, 2, 6, 2,
		6, 2, 6, 2, 6, 2, 6, 2,
		6, 2, 6, 2, 6, 2, 6, 2,
	]
}

const die_spacing = 1.2
@onready var dice = preload("res://die.tscn")

var bgm
var target_pos = position

func timings_from_beatmap(beatmap):
	var timings = []
	var beat_length_s = 60. / beatmap.bpm
	var dice_sequence = beatmap.dice
	
	for i in range(dice_sequence.size()):
		# in future will handle different beat divisions here
		timings.append(i * beat_length_s)

func _ready():
	add_to_group("levelgen")
	
	# setup bgm node to handle note timings
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	bgm.tempo = level.bpm
	bgm.audio = level.audio
	bgm.start_song()
	
	# generate dice sequence
	var prev_die = null
	var dice_sequence = level.dice
	for i in range(dice_sequence.size()):
		var die = dice.instantiate()
		
		if prev_die != null: prev_die.next = die
		
		die.spawn_face = dice_sequence[i]
		bgm.connect("on_beat", Callable(die, "_on_beat"))
		add_child(die)
		
		die.global_position = Vector3(die_spacing * i, 0, 0)
		if i == 0: die.active = true
		
		prev_die = die

func _process(_delta):
	position = lerp(position, target_pos, .1)
