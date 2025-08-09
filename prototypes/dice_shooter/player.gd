extends CharacterBody2D

const SPEED = 150

var sprite_facing = 1
var prev_dirspeed = 0

@onready var animation = $AnimatedSprite2D
@onready var bullet = preload("res://bullet.tscn")

func shoot(angle):
	var bullet_inst = bullet.instantiate()
	
	bullet_inst.creator = self
	bullet_inst.global_position = global_position
	bullet_inst.dir = Vector2.from_angle(angle)
	
	get_tree().current_scene.add_child(bullet_inst)
	
func _ready():
	add_to_group("player")

func _physics_process(_delta):
#	# Movement
	var dir = Vector2.ZERO
	dir.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	dir.y = int(Input.is_action_pressed("move_down" )) - int(Input.is_action_pressed("move_up"  ))
	velocity = dir.normalized() * SPEED
	move_and_slide()
	
	# Shooting
	if Input.is_action_just_pressed("shoot"):
		var mouse_pos = get_global_mouse_position()
		var angle = global_position.angle_to_point(mouse_pos)
		shoot(angle)
	
	# Animation
	if dir.x != 0: sprite_facing = -sign(dir.x)
	animation.scale.x = sprite_facing
	
	var dir_speed = dir.length()
	if dir_speed > 0 and prev_dirspeed == 0:
		animation.play("walk")
		
	if dir_speed == 0 and prev_dirspeed > 0:
		animation.stop()
		animation.frame = 0
		
	prev_dirspeed = dir_speed
