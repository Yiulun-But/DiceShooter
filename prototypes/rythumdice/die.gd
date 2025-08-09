extends Node3D

@export var active: bool = false
@export var spawn_face: int = 1

var finished = false
var dicepos
var next

var target_rot : Quaternion

var rot_angle = deg_to_rad(90)
var face_rotations = {
	1: Vector3(0,           0, 0),
	2: Vector3(rot_angle,   0, 0),
	3: Vector3(0, 0,  -rot_angle),
	4: Vector3(0, 0,   rot_angle),
	5: Vector3( -rot_angle, 0, 0),
	6: Vector3(2*rot_angle, 0, 0),
}

func move_to_next():
	if active:
		active   = false
		dicepos.target_pos.x -= dicepos.die_spacing
		
		await get_tree().process_frame
		if next: next.active = true

func _ready():
	rotation = face_rotations[spawn_face]
	dicepos  = get_tree().get_nodes_in_group("levelgen")[0]

func _process(_delta):	
	if active:
		if Input.is_action_just_pressed("up"   ): rotate_x( rot_angle)
		if Input.is_action_just_pressed("down" ): rotate_x(-rot_angle)
		if Input.is_action_just_pressed("right"): rotate_z( rot_angle)
		if Input.is_action_just_pressed("left" ): rotate_z(-rot_angle)

func _on_beat():
	move_to_next()
