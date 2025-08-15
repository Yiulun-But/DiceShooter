extends Node3D

@export var active: bool = false
@export var spawn_face: int = 1

@onready var hitsound = $hitsound

var finished = false
var levelgen
var next
var camera

# signal carries score emits when dice is deactivated
signal dice_finished(best_moves: bool, correct_facing: bool)
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
		levelgen.target_pos.x -= levelgen.DIE_SPACING
		
		# emit the signal for scoring
		var best_moves
		if spawn_face == 1:
			best_moves = moves <= 2
		elif spawn_face == 6:
			best_moves = moves == 0
		else:
			best_moves = moves <= 1
		
		dice_finished.emit(best_moves, is_complete())
		
		# wait for the next frame before activating the next dice, prevents bug where they both rotate at once
		await get_tree().process_frame
		
		# create a new dice if in level editing mode
		if levelgen.is_editor:
			var bgm = levelgen.bgm
			bgm.timings.append(bgm.timings.back() + levelgen.beat_length_s)
			levelgen.level_data.dice.append(6)
			next = levelgen.make_die(6)
			next.position.x = position.x + levelgen.DIE_SPACING
			
		
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
	
func player_action_rotate(axis, angle):
	rot(axis, angle)
	global.play_hitsound(hitsound)
	moves += 1
	

func _ready():
	camera   = get_tree().get_nodes_in_group("camera"  )[0]
	levelgen = get_tree().get_nodes_in_group("levelgen")[0]
	
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
	scale = Vector3.ONE
	if active:
		scale = Vector3.ONE * 1.1

func _input(event):
	if event is not InputEventKey: return
	if active and not event.echo:
		var camera_basis = camera.global_transform.basis
		if event.is_action_pressed("up"   ): player_action_rotate(camera_basis.x, -rot_angle)
		if event.is_action_pressed("down" ): player_action_rotate(camera_basis.x,  rot_angle)
		if event.is_action_pressed("right"): player_action_rotate(camera_basis.y,  rot_angle)
		if event.is_action_pressed("left" ): player_action_rotate(camera_basis.y, -rot_angle)


func _on_beat():
	move_to_next()
