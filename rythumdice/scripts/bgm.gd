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
	# use timing based on how much of the audio has played
	var song_elapsed = song.get_playback_position()
	
	if next_beat < timings.size() \
	   and song_elapsed >= timings[next_beat]:
		# sends a generic signal so UI and other game elements can connect to it and sync to the beat
		emit_signal("on_beat")
		next_beat += 1
		
	# if at the end of the song, emit one more signal
	elif next_beat == timings.size():
		var time_delayed = 60 / tempo
		await get_tree().create_timer(time_delayed).timeout
		emit_signal("on_beat")
