extends Node3D

@export var active: bool = false
@export var spawn_face: int = 1

var finished = false
var dicepos
var next
var camera

# signal carries score emits when dice is deactivated
signal dice_finished(moves: int, facing: int)
# signal when level is finished
signal level_finished()

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
	
func move_to_next():
	# disable controls for this dice and shift over to the next one
	if active:
		active = false
		dicepos.target_pos.x -= dicepos.DIE_SPACING
		
		# emit the signal for scoring
		dice_finished.emit(moves, is_complete())
		
		# wait for the next frame before activating the next dice, prevents bug where they both rotate at once
		await get_tree().process_frame
		if next:
			next.active = true
		else:
			level_finished.emit()
			
func is_complete():
	# check if 6 face normal vector is up
	var face_normal = Vector3.DOWN # 6 is facing down by default
	var world_normal = global_transform.basis * face_normal
	return world_normal.dot(Vector3.UP) > .45

func rot(axis, angle):
	var rotation_delta = Quaternion(axis, angle).normalized()
	target_rot = rotation_delta * target_rot

func _ready():
	camera     = get_tree().get_nodes_in_group("camera"  )[0]
	dicepos    = get_tree().get_nodes_in_group("levelgen")[0]
	
	# rotate so the correct face is up
	rotation   = face_rotations[spawn_face]
	target_rot = global_transform.basis.get_rotation_quaternion()

	moves = 0
func _process(_delta):
	# interpolate rotation
	var current_rot = global_transform.basis.get_rotation_quaternion()
	current_rot     = current_rot.slerp(target_rot, ROT_SPEED)
	transform.basis = Basis(current_rot)
	
	# controls for rotating the dice
	if active:
		var camera_basis = camera.global_transform.basis
		if Input.is_action_just_pressed("up"   ): 
			rot(camera_basis.x, -rot_angle)
			add_move_count()
		if Input.is_action_just_pressed("down" ): 
			rot(camera_basis.x,  rot_angle)
			add_move_count()
		if Input.is_action_just_pressed("right"): 
			rot(camera_basis.y,  rot_angle)
			add_move_count()
		if Input.is_action_just_pressed("left" ): 
			rot(camera_basis.y, -rot_angle)
			add_move_count()

func add_move_count():
	moves += 1

func _on_beat():
	move_to_next()
