extends Node2D

@export var dir: Vector2 = Vector2.ZERO
var creator
const SPEED = 300

func _physics_process(delta):
	position += dir * SPEED * delta 

func _on_body_entered(body: Node2D):
	# damage enemy
	if body.is_in_group("enemies"):
		body.queue_free()
	
	# destroy bullet
	if body != creator:
		queue_free()
