extends Node
var selected_level = ""
var N_HITSOUNDS = 25
var DICE_MISSED_MAX_ANGLE = 30

func play_hitsound(audio_stream_player):
	var index     = randi_range(1, global.N_HITSOUNDS)
	var index_str = str(index).pad_zeros(2)
	var filename  = "res://audio/hitsounds/dice-hit-" + index_str + ".wav"
	var stream    = load(filename)
	
	audio_stream_player.stream = stream
	audio_stream_player.play()
