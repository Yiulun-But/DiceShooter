extends Node3D

@export var active: bool = false
@export var spawn_face: int = 1

# signal carries score emits when dice is deactivated
signal dice_finished(moves: int, facing: int)

# moves count
var moves
var target_rot : Quaternion
const ROT_SPEED = .3

# list of (euclidean) rotations needed for each number to be on top
var rot_angle = deg_to_rad(90)
var face_rotations = {
	1: Vector3(0,           0, 0),
	2: Vector3(rot_angle,   0, 0),
	3: Vector3(0, 0,  -rot_angle),
	4: Vector3(0, 0,   rot_angle),
	5: Vector3( -rot_angle, 0, 0),
	6: Vector3(2*rot_angle, 0, 0),
}


func is_complete():
	# check if 6 face normal vector is up
	var face_normal = Vector3.DOWN # 6 is facing down by default
	var world_normal = global_transform.basis * face_normal
	return world_normal.dot(Vector3.UP) > .95

func rot(axis, angle):
	var rotation_delta = Quaternion(axis, angle).normalized()
	target_rot = rotation_delta * target_rot

func _ready():
	# rotate so the correct face is up
	rotation   = face_rotations[spawn_face]
	target_rot = global_transform.basis.get_rotation_quaternion()
	moves = 0

func _process(delta):
	# interpolate rotation
	var current_rot = global_transform.basis.get_rotation_quaternion()
	current_rot     = current_rot.slerp(target_rot, ROT_SPEED)
	transform.basis = Basis(current_rot)
	
	# controls for rotating the dice
	if active:
		if Input.is_action_just_pressed("up"): 
			rot(Vector3.RIGHT, -rot_angle)
			add_move_count()
		if Input.is_action_just_pressed("down"): 
			rot(Vector3.RIGHT,  rot_angle)
			add_move_count()
		if Input.is_action_just_pressed("right"): 
			rot(Vector3.UP,  rot_angle)
			add_move_count()
		if Input.is_action_just_pressed("left"): 
			rot(Vector3.UP, -rot_angle)
			add_move_count()

func add_move_count():
	moves += 1

func finish_dice():
	# Call this when you want to finish the dice in title scene
	if active:
		active = false
		dice_finished.emit(moves, get_current_face())

func get_current_face():
	# Helper function to determine which face is currently up
	# This is a simplified version - you might want to make it more robust
	for face in face_rotations:
		var face_rotation = face_rotations[face]
		var face_quat = Quaternion.from_euler(face_rotation)
		if target_rot.is_equal_approx(face_quat):
			return face
	return 1 # default to 1 if no match found
	
func _on_auto_rotate():
	var axes = [Vector3.RIGHT, Vector3.UP, Vector3.FORWARD]
	
	var random_axis = axes[randi() % axes.size()]
	var random_dir = 1 if randf() > 0.5 else -1
	rot(random_axis, rot_angle * random_dir)


func _on_timer_timeout() -> void:
	_on_auto_rotate()
