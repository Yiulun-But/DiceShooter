extends Node3D
@onready var die: Node3D = get_child(0)

func _ready() -> void:
	die.flash_face_1()
	

func _on_timer_timeout() -> void:
	die.flash_face_1()
