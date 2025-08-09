extends Node2D

@export var speed: float = 50.0        # pixels per second
@export var player_path: NodePath      # assign Player node in the inspector

var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	if player:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * speed * delta
