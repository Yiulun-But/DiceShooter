extends Node3D

@export_file("*.json") var level
@onready var hitobject = preload("res://scenes/hitobject.tscn")

var bgm
var level_data
var target_pos = position
const die_spacing = 1.2

func note_length(beatmap):
	return 60. / (beatmap.bpm * beatmap.subdivision)

func timings_from_beatmap(beatmap):
	# generates a list of timestamps where each beat hits
	var timings = []
	var beat_length_s = note_length(beatmap)
	var dice_sequence = beatmap.rows
	
	for i in range(dice_sequence.size()):
		# in future will handle different beat divisions here
		timings.append(i * beat_length_s)
		
	return timings

func _ready():
	add_to_group("levelgen")
	level_data  = load_json(level)
	var timings = timings_from_beatmap(level_data)
	
	# setup bgm node to handle note timings
	bgm = get_tree().get_nodes_in_group("bgm")[0]
	bgm.tempo   = level_data.bpm
	bgm.audio   = level_data.audio
	bgm.timings = timings
	bgm.note_duration = note_length(level_data)
	bgm.start_song()
	
	# generate hitobject sequence
	var hit_sequence = level_data.rows
	var jump_indexes = level_data.jumps
	for i in range(hit_sequence.size() - 1):
		# create the dice and connect them to the beat
		var row = hit_sequence[i]
		if row == null: continue
		
		var hit = hitobject.instantiate()
		hit.hit_time = timings[i+1]
		hit.row      = row
		
		if jump_indexes.has(float(i)): hit.is_jump_target = true
		add_child(hit)

func _process(_delta):
	# animate movement (move towards target position)
	position = lerp(position, target_pos, .1)
	
func load_json(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null: push_error("Could not open level file: \"", file_path, '"')
	
	var data = JSON.parse_string(file.get_as_text())
	if data == null: push_error("Invalid JSON in file: \"", file_path, '"')
	return data
