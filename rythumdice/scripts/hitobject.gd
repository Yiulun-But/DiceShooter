extends Node3D

var hit_time = 0
var row      = 0
var is_jump_target = false
var bgm
var player

var jumped = false

func update_position():
	var song_time = bgm.get_song_time()
	var speed = bgm.note_duration * config.track_length / config.row_height
	position.x = -lerp(
		0., 
		config.track_length, 
		(song_time - hit_time) / speed
	)

func _ready():
	bgm = get_tree().get_nodes_in_group("bgm"   )[0]
	
	# using .499 instead of .5 to avoid z-fighting
	position = Vector3(0, -.499, -row * config.row_height)
	update_position()
	
	if !is_jump_target: scale = Vector3.ONE * .7
	
func _process(_delta):
	update_position()
	
	#var time_delta    = bgm.get_song_time() - hit_time
	#var in_time_range = abs(time_delta) < bgm.note_duration
	
	#if is_jump_target and in_time_range:
		#if Input.is_action_just_pressed("jump"):
			#signals.emit_signal("player_jump", row)
			
	# autojump
	var passed_beat = bgm.get_song_time() > hit_time - bgm.note_duration
	if not jumped and is_jump_target and passed_beat:
		signals.emit_signal("_player_jump", row)
		jumped = true
		
