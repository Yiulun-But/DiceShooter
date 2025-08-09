extends Node
signal  on_beat

var tempo
var audio
var timings
var next_beat = 1

@onready var song = $song

func _ready():
	add_to_group("bgm")
	
func start_song():
	var audio_stream = load(audio)
	song.stream = audio_stream
	song.play()

func _process(_delta):
	var song_elapsed = song.get_playback_position()
	if next_beat < timings.size() and song_elapsed >= timings[next_beat]:
		emit_signal("on_beat")
		next_beat += 1
