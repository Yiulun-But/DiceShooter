extends ColorRect

@export var scroll_speed: float = 1.0
var current_scroll: float = 0.5
var shader_material = material as ShaderMaterial

func _ready():
	pass

func _process(delta):
	# Update scroll position
	current_scroll += scroll_speed * delta
	
	# Apply to shader
	shader_material = material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("scroll_offset", current_scroll)
