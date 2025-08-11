extends Node

var tempo
var audio
var timings
var next_beat = 1
var note_duration

@onready var song = $song

func get_song_time():
	return song.get_playback_position()

func _ready():
	add_to_group("bgm")
	
func start_song():
	var audio_stream = load(audio)
	song.stream = audio_stream
	song.play()

func _process(_delta):
	# use timing based on how much of the audio has played
	var song_elapsed = get_song_time()
	if next_beat < timings.size() \
	   and song_elapsed >= timings[next_beat]:
		# sends a generic signal so UI and other game elements can connect to it and sync to the beat
		signals.emit_signal("_on_beat")
		next_beat += 1
