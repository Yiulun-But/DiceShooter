extends Node
signal  on_beat

var tempo
var audio
var timings
var next_beat = 1

@onready var beat_label = $beat_label
@onready var song = $song
@onready var floating_text = preload("res://scenes/floating_text.tscn")

# prompt data
var prompts = {
	3: "Hello, this is 3th beat",
	30: "Well, 30th right now"
}

func _ready():
	add_to_group("bgm")
	
func start_song():
	var audio_stream = load(audio)
	song.stream = audio_stream
	song.play()

func _process(_delta):
	# use timing based on how much of the audio has played
	var song_elapsed = song.get_playback_position()
	
	if next_beat < timings.size() \
	   and song_elapsed >= timings[next_beat]:
		# sends a generic signal so UI and other game elements can connect to it and sync to the beat
		emit_signal("on_beat")
		next_beat += 1
		beat_label.text = str(next_beat - 1)
		
		check_prompt(next_beat - 1)
		
	# if at the end of the song, emit one more signal
	elif next_beat == timings.size():
		var time_delayed = 60 / tempo
		await get_tree().create_timer(time_delayed).timeout
		emit_signal("on_beat")

# check if current beat has a related prompt
func check_prompt(beat: int):
	if prompts.has(beat):
		add_prompt(prompts[beat], 3.0)
		
# add the prompt text to the game
func add_prompt(txt: String, duration: float):
	var text_inst = floating_text.instantiate()
	text_inst.set_text_and_colour(txt, Color.WHITE)
	text_inst.set_time_out(5.0)
	text_inst.position = Vector3(0, 0.2, -2)
	add_child(text_inst)
