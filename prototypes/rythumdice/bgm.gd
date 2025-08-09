extends Node

signal on_beat

@export  var bpm: int = 120
@export  var subdivision: int = 1
@onready var layers = {
	"kick":  $kick
}
@onready var beat_timer = $beat

var beat_length_s = 60. / bpm

func _ready():
	add_to_group("bgm")
	
	beat_timer.wait_time = beat_length_s
	beat_timer.one_shot = false
	beat_timer.start()
	
	for layer in layers.values():
		layer.volume_db = -80
		layer.play()
		
	add_layer("kick")

func add_layer(layer):
	var layer_audio = layers[layer]
	layer_audio.volume_db = 0

func _on_beat_timeout():
	emit_signal("on_beat")
