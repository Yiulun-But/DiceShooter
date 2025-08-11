extends Node3D

@export_file("*.json") var level
@export var new_level_name: String
@onready var dice = preload("res://scenes/die.tscn")

var bgm
var level_data
var target_pos = position
var beat_length_s
const DIE_SPACING = 1.2

# editor data
var is_editor = false
var input_directions = ["up", "down", "left", "right"]
var input_map = {
	"up":    5,
	"down":  2,
	"left":  3,
	"right": 4
}

func timings_from_beatmap(beatmap):
	# generates a list of timestamps where each beat hits
	beat_length_s = beatmap.beats_per_die * 60. / beatmap.bpm 
	
	var timings = []
	var dice_sequence = beatmap.dice
	
	for i in range(dice_sequence.size()):
		# in future will handle different beat divisions here
		timings.append(i * beat_length_s - beat_length_s/2)
		
	return timings
	
func make_die(up_face):
	var die = dice.instantiate()
	die.spawn_face = up_face
	bgm.connect("on_beat", Callable(die, "_on_beat"))
	add_child(die)
	return die

func _ready():
	add_to_group("levelgen")
	level_data = load_json(level)
	
	if level == "res://levels/new_level.json":
		is_editor = true
		level_data.dice = [6, 6]
	
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
		var die = make_die(dice_sequence[i])
		die.global_position = Vector3(DIE_SPACING * i, 0, 0)
		
		# activate the first die and connect each one to the next in order
		if i == 0: die.active = true
		if prev_die != null: prev_die.next = die
		prev_die = die
		

func _process(_delta):
	# animate movement (move towards target position)
	position = lerp(position, target_pos, .1)
	
	if is_editor:
		# record player input and modify the level data directly
		for direction in input_directions:
			if Input.is_action_just_pressed(direction):
				var beat_ind = bgm.next_beat - 1
				if level_data.dice[beat_ind] == 6:
					level_data.dice[beat_ind] = input_map[direction]
				else:
					# if current index is not six then its the second press this beat
					level_data.dice[beat_ind] = 1
					
		if Input.is_action_just_pressed("save_level"):
			save_json("res://levels/" + new_level_name + ".json", level_data)
		
	
func load_json(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null: push_error("Could not open level file: \"", file_path, '"')
	
	var data = JSON.parse_string(file.get_as_text())
	if data == null: push_error("Invalid JSON in file: \"", file_path, '"')
	return data
	
func save_json(file_path, data):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null: push_error("Could not open level file for saving: \"", file_path, '"')
	
	var json = JSON.stringify(data)
	file.store_string(json)
	file.close()
