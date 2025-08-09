extends Node3D

@export var active: bool = false
@export var spawn_face: int = 1

var finished = false
var dicepos
var next
var camera

var target_rot : Quaternion
const ROT_SPEED = .3

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
		
func rot(axis, angle):
	var rotation_delta = Quaternion(axis, angle).normalized()
	target_rot = rotation_delta * target_rot

func _ready():
	camera     = get_tree().get_nodes_in_group("camera"  )[0]
	dicepos    = get_tree().get_nodes_in_group("levelgen")[0]
	
	rotation   = face_rotations[spawn_face]
	target_rot = global_transform.basis.get_rotation_quaternion()

func _process(_delta):
	# interpolate rotation
	var current_rot = global_transform.basis.get_rotation_quaternion()
	current_rot     = current_rot.slerp(target_rot, ROT_SPEED)
	transform.basis = Basis(current_rot)
	
	if active:
		var camera_basis = camera.global_transform.basis
		if Input.is_action_just_pressed("up"   ): rot(camera_basis.x, -rot_angle)
		if Input.is_action_just_pressed("down" ): rot(camera_basis.x,  rot_angle)
		if Input.is_action_just_pressed("right"): rot(camera_basis.y,  rot_angle)
		if Input.is_action_just_pressed("left" ): rot(camera_basis.y, -rot_angle)

func _on_beat():
	move_to_next()
