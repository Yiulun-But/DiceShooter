extends MeshInstance3D

var target_scale  = 1.
var current_scale = 1.

func _process(_delta):
	current_scale = lerp(current_scale, target_scale, .1)
	scale = Vector3.ONE * current_scale

func _on_beat():
	current_scale = 1.2
