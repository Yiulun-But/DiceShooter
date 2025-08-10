extends Node3D

@export_file("*.json") var level
@onready var dice = preload("res://scenes/die.tscn")

var bgm
var level_data
var target_pos = position
const die_spacing = 1.2

func timings_from_beatmap(beatmap):
	# generates a list of timestamps where each beat hits
	var timings = []
	var beat_length_s = 60. / beatmap.bpm
	var dice_sequence = beatmap.dice
	
	for i in range(dice_sequence.size()):
		# in future will handle different beat divisions here
		timings.append(i * beat_length_s)
		
	return timings

func _ready():
	add_to_group("levelgen")
	level_data = load_json(level)
	
	# setup bgm node to handle note timings
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	bgm.tempo   = level_data.bpm
	bgm.audio   = level_data.audio
	bgm.timings = timings_from_beatmap(level_data)
	bgm.start_song()
	
	# generate dice sequence
	var prev_die = null
	var dice_sequence = level_data.dice
	for i in range(dice_sequence.size()):
		# create the dice and connect them to the beat
		var die = dice.instantiate()
		die.spawn_face = dice_sequence[i]
		bgm.connect("on_beat", Callable(die, "_on_beat"))
		add_child(die)
		
		# move the die to the end of the line
		die.global_position = Vector3(die_spacing * i, 0, 0)
		
		# activate the first die and connect each one to the next in order
		if i == 0: die.active = true
		if prev_die != null: prev_die.next = die
		prev_die = die

func _process(_delta):
	# animate movement (move towards target position)
	position = lerp(position, target_pos, .1)
	
func load_json(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null: push_error("Could not open level file: \"", file_path, '"')
	
	var data = JSON.parse_string(file.get_as_text())
	if data == null: push_error("Invalid JSON in file: \"", file_path, '"')
	return data
