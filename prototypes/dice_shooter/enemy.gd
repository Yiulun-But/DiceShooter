extends CharacterBody2D

var player 
const SPEED = 50

func _ready():
	add_to_group("enemies")
	player = get_tree().get_nodes_in_group("player")[0]
	
func _physics_process(_delta):
	var direction = player.global_position - global_position
	velocity = direction.normalized() * SPEED
	move_and_slide()
