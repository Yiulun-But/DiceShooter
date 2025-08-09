extends Node

signal on_beat

var tempo: int = 120
var audio
@onready var song = $song
@onready var beat_timer = $beat

var beat_length_s = 60. / tempo

func _ready():
	add_to_group("bgm")
	
	beat_timer.wait_time = beat_length_s
	beat_timer.one_shot = false
	beat_timer.start()
	
	var audio_stream = load(song.audio)
	song.stream = audio_stream
	song.play()

func _on_beat_timeout():
	emit_signal("on_beat")
